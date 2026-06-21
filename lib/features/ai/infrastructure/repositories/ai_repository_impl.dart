import 'dart:async';
import 'package:drift/drift.dart' hide Column;
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

  final _taskEventsController = StreamController<List<AiTaskEvent>>.broadcast();
  final List<AiTaskEvent> _activeTasks = [];

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
  Stream<List<AiTaskEvent>> get taskEvents => _taskEventsController.stream;

  @override
  void logActivity(String taskId, String title, TaskState state, {String? error}) {
    _addOrUpdateTask(taskId, title, state, error: error);
  }

  void _addOrUpdateTask(String taskId, String title, TaskState state, {String? error}) {
    final index = _activeTasks.indexWhere((t) => t.taskId == taskId);
    if (index >= 0) {
      _activeTasks[index] = _activeTasks[index].copyWith(state: state, error: error);
    } else {
      _activeTasks.add(AiTaskEvent(
        taskId: taskId,
        title: title,
        state: state,
        error: error,
        timestamp: DateTime.now(),
      ));
    }
    _taskEventsController.add(List.unmodifiable(_activeTasks));
  }

  void _clearTasks() {
    _activeTasks.clear();
    _taskEventsController.add([]);
  }

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

    _clearTasks();
    _addOrUpdateTask('analyzing', 'Analyzing request...', TaskState.running);

    String responseText = "";
    try {
      responseText = await _runGeminiAgentFlow(apiKey, message);
      _addOrUpdateTask('analyzing', 'Analyzing request...', TaskState.completed);
    } catch (e) {
      _addOrUpdateTask('analyzing', 'Analyzing request...', TaskState.failed, error: e.toString());
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
    final systemPrompt =
        "You are an academic assistant for a student. "
        "You have access to the following tool call tags. If the user's request requires external data or action, you must output the corresponding tag(s). You can output multiple tags if multiple actions are needed (for example, to schedule multiple study sessions, output one tag per session):\n"
        "- To fetch Google Classroom deadlines: output '[CALL:list_classroom_deadlines]'\n"
        "- To search Google Drive: output '[CALL:search_google_drive query=\"<keyword>\"]'\n"
        "- To create a calendar event: output '[CALL:create_calendar_event title=\"<title>\" hoursFromNow=<hours> durationHours=<duration>]'\n"
        "- To list recent emails: output '[CALL:list_recent_emails]'\n"
        "If the user's request does not require tools, respond directly in a friendly, helpful, conversational Indonesian language (without using any emojis).";

    final modelName = await _secureStorage.getGeminiModel() ?? 'models/gemini-1.5-flash';
    final model = GenerativeModel(
      model: modelName,
      apiKey: apiKey,
      systemInstruction: Content.system(systemPrompt),
    );

    // Load full history from db (excluding the current user message at the end)
    final pastChats = await (_db.select(_db.chats)
          ..orderBy([(t) => OrderingTerm(expression: t.timestamp)]))
        .get();

    final List<Content> history = [];
    for (int i = 0; i < pastChats.length - 1; i++) {
      final chat = pastChats[i];
      if (chat.role == 'user') {
        history.add(Content('user', [TextPart(chat.content)]));
      } else if (chat.role == 'model') {
        history.add(Content('model', [TextPart(chat.content)]));
      }
    }

    final chatSession = model.startChat(history: history);
    final response = await chatSession.sendMessage(Content.text(userPrompt));
    final responseText = response.text ?? "";

    final callRegex = RegExp(r'\[CALL:(\w+)([^\]]*)\]');
    final matches = callRegex.allMatches(responseText).toList();

    if (matches.isNotEmpty) {
      final List<String> results = [];

      for (final match in matches) {
        final toolName = match.group(1);
        final argsString = match.group(2) ?? "";

        if (toolName == 'list_classroom_deadlines') {
          _addOrUpdateTask('classroom_tool', 'Fetching Classroom assignments...', TaskState.running);
          try {
            final assignments = await _classroomRepo.fetchAssignments(forceRefresh: true);
            final deadlineText = assignments.map((a) => "- ${a.courseName}: ${a.title} (Due: ${a.dueTime})").join("\n");
            _addOrUpdateTask('classroom_tool', 'Fetching Classroom assignments...', TaskState.completed);
            results.add("Classroom Deadlines:\n$deadlineText");
          } catch (e) {
            _addOrUpdateTask('classroom_tool', 'Fetching Classroom assignments...', TaskState.failed, error: e.toString());
            results.add("Gagal mengambil data Classroom: $e");
          }
        }

        else if (toolName == 'search_google_drive') {
          final queryReg = RegExp(r'query="([^"]+)"');
          final queryMatch = queryReg.firstMatch(argsString);
          final query = queryMatch?.group(1) ?? "";

          _addOrUpdateTask('drive_tool', 'Searching related Drive files...', TaskState.running);
          try {
            final files = await _driveRepo.searchFiles(query);
            final fileText = files.map((f) => "- [${f.name}](${f.webViewLink})").join("\n");
            _addOrUpdateTask('drive_tool', 'Searching related Drive files...', TaskState.completed);
            results.add("Drive Files for query '$query':\n$fileText");
          } catch (e) {
            _addOrUpdateTask('drive_tool', 'Searching related Drive files...', TaskState.failed, error: e.toString());
            results.add("Gagal mencari file Drive untuk '$query': $e");
          }
        }

        else if (toolName == 'list_recent_emails') {
          _addOrUpdateTask('gmail_tool', 'Reading recent emails...', TaskState.running);
          try {
            final emails = await _emailRepo.fetchRecentEmails(forceRefresh: true);
            final emailText = emails.map((e) => "- From: ${e.sender}\n  Subject: ${e.subject}\n  Summary: ${e.bodySummary ?? e.snippet}").join("\n\n");
            _addOrUpdateTask('gmail_tool', 'Reading recent emails...', TaskState.completed);
            results.add("Recent Academic Emails:\n$emailText");
          } catch (e) {
            _addOrUpdateTask('gmail_tool', 'Reading recent emails...', TaskState.failed, error: e.toString());
            results.add("Gagal membaca email: $e");
          }
        }

        else if (toolName == 'create_calendar_event') {
          final titleReg = RegExp(r'title="([^"]+)"');
          final hoursReg = RegExp(r'hoursFromNow="?(\d+)"?');
          final durationReg = RegExp(r'durationHours="?(\d+)"?');

          final title = titleReg.firstMatch(argsString)?.group(1) ?? "Study Session";
          final hoursFromNow = int.tryParse(hoursReg.firstMatch(argsString)?.group(1) ?? "2") ?? 2;
          final durationHours = int.tryParse(durationReg.firstMatch(argsString)?.group(1) ?? "1") ?? 1;

          final start = DateTime.now().add(Duration(hours: hoursFromNow));
          final end = start.add(Duration(hours: durationHours));

          final taskKey = 'calendar_tool_${title.hashCode}_$hoursFromNow';
          _addOrUpdateTask(taskKey, 'Creating calendar event "$title"...', TaskState.running);
          try {
            final created = await _calendarRepo.createEvent(CalendarEvent(
              id: "",
              title: title,
              description: "Generated by DeadlineAI assistant",
              startTime: start,
              endTime: end,
            ));
            _addOrUpdateTask(taskKey, 'Creating calendar event "$title"...', TaskState.completed);
            results.add("Berhasil membuat jadwal: '${created.title}' pada $start");
          } catch (e) {
            _addOrUpdateTask(taskKey, 'Creating calendar event "$title"...', TaskState.failed, error: e.toString());
            results.add("Gagal membuat jadwal '$title': $e");
          }
        }
      }

      _addOrUpdateTask('building', 'Building response...', TaskState.running);
      final aggregatedResult = results.join("\n\n");
      final toolResponse = await chatSession.sendMessage(Content.text(
        "Here are the tool call results:\n\n$aggregatedResult\n\nSummarize and present them to the student in friendly Indonesian (without using emojis)."
      ));
      _addOrUpdateTask('building', 'Building response...', TaskState.completed);
      return toolResponse.text ?? "Berikut hasilnya:\n$aggregatedResult";
    }

    _addOrUpdateTask('building', 'Building response...', TaskState.running);
    await Future.delayed(const Duration(milliseconds: 300));
    _addOrUpdateTask('building', 'Building response...', TaskState.completed);

    return responseText;
  }
}
