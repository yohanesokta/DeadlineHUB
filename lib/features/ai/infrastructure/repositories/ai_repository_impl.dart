import 'dart:async';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:deadlinehub/core/database/database.dart';
import 'package:deadlinehub/core/services/secure_storage_service.dart';
import 'package:deadlinehub/features/ai/domain/repositories/ai_repository.dart';
import 'package:deadlinehub/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:deadlinehub/features/calendar/domain/entities/calendar_event.dart';
import 'package:deadlinehub/features/drive/domain/repositories/drive_repository.dart';
import 'package:deadlinehub/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:deadlinehub/features/email/domain/repositories/email_repository.dart';
import 'package:uuid/uuid.dart';

class AIRepositoryImpl implements AIRepository {
  final AppDatabase _db;
  final SecureStorageService _secureStorage;
  final CalendarRepository _calendarRepo;
  final DriveRepository _driveRepo;
  final ClassroomRepository _classroomRepo;
  final EmailRepository _emailRepo;

  AIRepositoryImpl({
    required AppDatabase db,
    required SecureStorageService secureStorage,
    required CalendarRepository calendarRepo,
    required DriveRepository driveRepo,
    required ClassroomRepository classroomRepo,
    required EmailRepository emailRepo,
  })  : _db = db,
        _secureStorage = secureStorage,
        _calendarRepo = calendarRepo,
        _driveRepo = driveRepo,
        _classroomRepo = classroomRepo,
        _emailRepo = emailRepo;

  @override
  Future<String> chat(String message) async {
    // Save user message to Drift SQLite DB
    final userMsgId = const Uuid().v4();
    await _db.into(_db.chats).insert(
      ChatsCompanion.insert(
        id: userMsgId,
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      ),
    );

    final apiKey = await _secureStorage.getGeminiApiKey();
    String responseText = "";

    if (apiKey != null && apiKey.isNotEmpty && apiKey != "mock_key") {
      try {
        responseText = await _runGeminiAgentFlow(apiKey, message);
      } catch (e) {
        responseText = "Error communicating with Gemini API: $e. Falling back to agent simulation.\n\n${_runMockAgentFlow(message)}";
      }
    } else {
      // Simulate tool calling agent flow locally for immediate prototyping
      await Future.delayed(const Duration(seconds: 1));
      responseText = await _runMockAgentFlow(message);
    }

    // Save AI response to database
    final aiMsgId = const Uuid().v4();
    await _db.into(_db.chats).insert(
      ChatsCompanion.insert(
        id: aiMsgId,
        role: 'model',
        content: responseText,
        timestamp: DateTime.now(),
      ),
    );

    return responseText;
  }

  @override
  Stream<String> chatStream(String message) async* {
    // For simplicity, yield the full response in chunked delay simulations
    final result = await chat(message);
    final words = result.split(' ');
    String current = "";
    for (final word in words) {
      current += "$word ";
      yield current;
      await Future.delayed(const Duration(milliseconds: 30));
    }
  }

  @override
  Future<void> clearHistory() async {
    await _db.delete(_db.chats).go();
  }

  /// Run Gemini with tools definition
  Future<String> _runGeminiAgentFlow(String apiKey, String userPrompt) async {
    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
      tools: [
        Tool(functionDeclarations: [
          FunctionDeclaration(
            'list_classroom_deadlines',
            'Fetches student deadlines and course assignments',
            Schema.object(properties: {}),
          ),
          FunctionDeclaration(
            'search_google_drive',
            'Search for course documents and files in Google Drive',
            Schema.object(properties: {
              'query': Schema.string(description: 'File name keyword to search'),
            }, requiredProperties: ['query']),
          ),
          FunctionDeclaration(
            'create_calendar_event',
            'Creates a study session or calendar event block',
            Schema.object(properties: {
              'title': Schema.string(description: 'Event title'),
              'hoursFromNow': Schema.integer(description: 'Start time represented in hours from now'),
              'durationHours': Schema.integer(description: 'Duration of study block in hours'),
            }, requiredProperties: ['title', 'hoursFromNow', 'durationHours']),
          ),
        ]),
      ],
    );

    final chatSession = model.startChat();
    var response = await chatSession.sendMessage(Content.text(userPrompt));

    final functionCalls = response.functionCalls;
    if (functionCalls.isEmpty) {
      return response.text ?? "I couldn't process that request.";
    }

    // Process tool calls requested by Gemini
    final functionCall = functionCalls.first;
    if (functionCall.name == 'list_classroom_deadlines') {
      final assignments = await _classroomRepo.fetchAssignments();
      final deadlineText = assignments.map((a) => "- ${a.courseName}: ${a.title} (Due: ${a.dueTime})").join("\n");
      
      final toolResponse = await chatSession.sendMessage(Content.functionResponse(
        functionCall.name,
        {'result': deadlineText},
      ));
      return toolResponse.text ?? "Here are your deadlines:\n$deadlineText";
    } 
    
    if (functionCall.name == 'search_google_drive') {
      final queryArg = functionCall.args['query'] as String? ?? "";
      final files = await _driveRepo.searchFiles(queryArg);
      final fileText = files.map((f) => "- [${f.name}](${f.webViewLink})").join("\n");
      
      final toolResponse = await chatSession.sendMessage(Content.functionResponse(
        functionCall.name,
        {'result': fileText},
      ));
      return toolResponse.text ?? "Here are the files I found:\n$fileText";
    }

    if (functionCall.name == 'create_calendar_event') {
      final title = functionCall.args['title'] as String? ?? "Study Block";
      final hoursFromNow = functionCall.args['hoursFromNow'] as int? ?? 1;
      final duration = functionCall.args['durationHours'] as int? ?? 1;

      final start = DateTime.now().add(Duration(hours: hoursFromNow));
      final end = start.add(Duration(hours: duration));

      final created = await _calendarRepo.createEvent(CalendarEvent(
        id: "",
        title: title,
        description: "Generated by DeadlineAI assistant",
        startTime: start,
        endTime: end,
      ));

      final toolResponse = await chatSession.sendMessage(Content.functionResponse(
        functionCall.name,
        {'result': 'Created event ${created.title} starting at ${created.startTime}'},
      ));
      return toolResponse.text ?? "Successfully scheduled study block: ${created.title}.";
    }

    return response.text ?? "Completed agent actions.";
  }

  /// Interactive simulated tool-calling flow
  Future<String> _runMockAgentFlow(String prompt) async {
    final query = prompt.toLowerCase();
    
    if (query.contains('deadline') || query.contains('tugas') || query.contains('classroom')) {
      final items = await _classroomRepo.fetchAssignments();
      final list = items.map((a) => "• **${a.courseName}**: ${a.title}\n  *Due: ${a.dueTime?.toLocal()}*").join("\n");
      return "🔍 **[Tool: Classroom Monitor]** Fetching assignments from SQLite database...\n\nHere are your upcoming coursework items:\n\n$list\n\nWould you like me to schedule study sessions for any of these?";
    }

    if (query.contains('schedule') || query.contains('belajar') || query.contains('calendar')) {
      final now = DateTime.now();
      final event = CalendarEvent(
        id: 'gen_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Study Session: Linear Algebra Review',
        description: 'Auto-scheduled by DeadlineAI for: $prompt',
        startTime: now.add(const Duration(days: 1, hours: 2)),
        endTime: now.add(const Duration(days: 1, hours: 4)),
      );
      await _calendarRepo.createEvent(event);
      return "📅 **[Tool: Calendar Creator]** Creating event in Google Calendar...\n\nI've scheduled a study block for you:\n\n* **Event**: ${event.title}\n* **Time**: ${event.startTime.toLocal()} to ${event.endTime.toLocal()}\n\nLet me know if you want to modify this slot.";
    }

    if (query.contains('drive') || query.contains('cari file') || query.contains('spreadsheet') || query.contains('proposal')) {
      final term = query.contains('spreadsheet') ? 'spreadsheet' : (query.contains('proposal') ? 'proposal' : 'learning');
      final files = await _driveRepo.searchFiles(term);
      if (files.isEmpty) {
        return "📁 **[Tool: Drive Quick Access]** Searching files...\n\nNo files found matching key '$term'.";
      }
      final fileList = files.map((f) => "• [${f.name}](${f.webViewLink}) (Modified: ${f.modifiedTime})").join("\n");
      return "📁 **[Tool: Drive Quick Access]** Searching files matching '$term'...\n\nI found the following items in your Google Drive:\n\n$fileList";
    }

    if (query.contains('email') || query.contains('surat') || query.contains('dosen')) {
      final emails = await _emailRepo.fetchRecentEmails();
      final summaryList = emails.where((e) => e.isAcademic).map((e) => "• **${e.sender}**:\n  *Subject: ${e.subject}*\n  *Summary: ${e.bodySummary}*").join("\n\n");
      return "✉️ **[Tool: Academic Email Dashboard]** Reading and analyzing academic emails...\n\nHere is your digest:\n\n$summaryList";
    }

    if (query.contains('meet') || query.contains('rapat') || query.contains('kelompok')) {
      final now = DateTime.now();
      final event = CalendarEvent(
        id: 'gen_meet_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Group Project Sync',
        description: 'Discussing final report milestone',
        startTime: now.add(const Duration(hours: 4)),
        endTime: now.add(const Duration(hours: 5)),
        meetLink: 'https://meet.google.com/xyz-mock-meet',
      );
      await _calendarRepo.createEvent(event);
      return "📹 **[Tool: Meet Scheduler]** Generating meeting invitation...\n\nI have scheduled the group meeting and generated the link:\n\n* **Title**: ${event.title}\n* **Time**: ${event.startTime.toLocal()}\n* **Meet Link**: ${event.meetLink}\n\nInvitations have been sent to participants!";
    }

    // Default conversational response
    return "Hi, I am your DeadlineAI academic assistant. You can ask me to:\n"
        "• *Show upcoming deadlines* (Classroom Monitor)\n"
        "• *Schedule a study session* (Calendar Creator)\n"
        "• *Search for a file* (Drive Quick Access)\n"
        "• *Create a meeting* (Meet Scheduler)\n"
        "• *Summarize academic emails* (Gmail Reader)";
  }
}
