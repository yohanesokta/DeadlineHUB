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
    final apiKey = await _secureStorage.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API Key is missing. Connect account first.');
    }

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

    String responseText = "";
    try {
      responseText = await _runGeminiAgentFlow(apiKey, message);
    } catch (e) {
      responseText = "Error communicating with Gemini Agent: $e";
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

  /// Run Gemini with tools definition using real Google Workspace repositories
  Future<String> _runGeminiAgentFlow(String apiKey, String userPrompt) async {
    final modelName = await _secureStorage.getGeminiModel() ?? 'models/gemini-2.0-flash';
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      tools: [
        Tool(functionDeclarations: [
          FunctionDeclaration(
            'list_classroom_deadlines',
            'Fetches student deadlines and course assignments from Google Classroom',
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
          FunctionDeclaration(
            'list_recent_emails',
            'Fetches student academic and course-related emails from Gmail',
            Schema.object(properties: {}),
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
      final assignments = await _classroomRepo.fetchAssignments(forceRefresh: true);
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

    if (functionCall.name == 'list_recent_emails') {
      final emails = await _emailRepo.fetchRecentEmails(forceRefresh: true);
      final emailText = emails.map((e) => "- From: ${e.sender}\n  Subject: ${e.subject}\n  Summary: ${e.bodySummary ?? e.snippet}").join("\n\n");
      
      final toolResponse = await chatSession.sendMessage(Content.functionResponse(
        functionCall.name,
        {'result': emailText},
      ));
      return toolResponse.text ?? "Here is your email digest:\n$emailText";
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
}
