import 'dart:async';
import 'dart:convert';
import 'package:googleapis/calendar/v3.dart' as calendar;
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:deadlinehub/features/calendar/domain/entities/calendar_event.dart';
import 'package:deadlinehub/features/calendar/domain/repositories/calendar_repository.dart';
import 'package:deadlinehub/features/auth/domain/repositories/auth_repository.dart';
import 'package:deadlinehub/core/services/secure_storage_service.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final AuthRepository _authRepo;
  final SecureStorageService _secureStorage;

  CalendarRepositoryImpl(this._authRepo, this._secureStorage);

  @override
  Future<List<CalendarEvent>> fetchEvents({DateTime? start, DateTime? end}) async {
    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }

    final api = calendar.CalendarApi(client);
    final eventsRes = await api.events.list(
      'primary',
      timeMin: start?.toUtc() ?? DateTime.now().subtract(const Duration(days: 7)).toUtc(),
      timeMax: end?.toUtc() ?? DateTime.now().add(const Duration(days: 30)).toUtc(),
      singleEvents: true,
      orderBy: 'startTime',
    );

    final items = eventsRes.items ?? [];
    return items.map((e) {
      final startDt = e.start?.dateTime ?? e.start?.date;
      final endDt = e.end?.dateTime ?? e.end?.date;
      
      return CalendarEvent(
        id: e.id ?? '',
        title: e.summary ?? 'No Title',
        description: e.description ?? '',
        startTime: startDt?.toLocal() ?? DateTime.now(),
        endTime: endDt?.toLocal() ?? DateTime.now().add(const Duration(hours: 1)),
        isAllDay: e.start?.dateTime == null,
        meetLink: e.hangoutLink,
      );
    }).toList();
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }

    final api = calendar.CalendarApi(client);

    // Prepare Google Calendar Event schema
    final insertEvent = calendar.Event(
      summary: event.title,
      description: event.description,
      start: calendar.EventDateTime(dateTime: event.startTime.toUtc()),
      end: calendar.EventDateTime(dateTime: event.endTime.toUtc()),
    );

    // Check if we need to provision Google Meet conference link
    if (event.meetLink != null || event.title.toLowerCase().contains('meet') || event.description.toLowerCase().contains('meet')) {
      insertEvent.conferenceData = calendar.ConferenceData(
        createRequest: calendar.CreateConferenceRequest(
          requestId: 'meet_${DateTime.now().millisecondsSinceEpoch}',
          conferenceSolutionKey: calendar.ConferenceSolutionKey(type: 'hangoutsMeet'),
        ),
      );
    }

    // Specifying conferenceDataVersion: 1 tells Google API to provision conference resources
    final created = await api.events.insert(
      insertEvent,
      'primary',
      conferenceDataVersion: 1,
    );

    final startDt = created.start?.dateTime ?? created.start?.date;
    final endDt = created.end?.dateTime ?? created.end?.date;

    return CalendarEvent(
      id: created.id ?? '',
      title: created.summary ?? '',
      description: created.description ?? '',
      startTime: startDt?.toLocal() ?? event.startTime,
      endTime: endDt?.toLocal() ?? event.endTime,
      isAllDay: created.start?.dateTime == null,
      meetLink: created.hangoutLink,
    );
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }
    final api = calendar.CalendarApi(client);
    await api.events.delete('primary', eventId);
  }

  @override
  Future<CalendarEvent> updateEvent(CalendarEvent event) async {
    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }

    final api = calendar.CalendarApi(client);

    // Prepare Google Calendar Event schema
    final patchEvent = calendar.Event(
      summary: event.title,
      description: event.description,
      start: calendar.EventDateTime(dateTime: event.startTime.toUtc()),
      end: calendar.EventDateTime(dateTime: event.endTime.toUtc()),
    );

    final updated = await api.events.patch(
      patchEvent,
      'primary',
      event.id,
    );

    final startDt = updated.start?.dateTime ?? updated.start?.date;
    final endDt = updated.end?.dateTime ?? updated.end?.date;

    return CalendarEvent(
      id: updated.id ?? '',
      title: updated.summary ?? '',
      description: updated.description ?? '',
      startTime: startDt?.toLocal() ?? event.startTime,
      endTime: endDt?.toLocal() ?? event.endTime,
      isAllDay: updated.start?.dateTime == null,
      meetLink: updated.hangoutLink,
    );
  }

  @override
  Future<List<CalendarEvent>> generateScheduleFromPrompt(String prompt) async {
    final apiKey = await _secureStorage.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API Key missing. Please provide it in settings.');
    }

    final modelName = await _secureStorage.getGeminiModel() ?? 'models/gemini-2.0-flash';
    final model = gemini.GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );

    final now = DateTime.now();
    final timeZoneOffset = now.timeZoneOffset;
    final offsetSign = timeZoneOffset.isNegative ? '-' : '+';
    final offsetHours = timeZoneOffset.inHours.abs().toString().padLeft(2, '0');
    final offsetMinutes = (timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final offsetString = '$offsetSign$offsetHours:$offsetMinutes';
    final currentLocalTimeStr = "${now.toIso8601String().split('.').first}$offsetString";

    const weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    final weekdayName = weekdays[now.weekday - 1];

    final systemInstruction = 
        "You are an academic student scheduler. Parse the user's prompt into a study schedule starting from the user's current local time: $currentLocalTimeStr ($weekdayName, timezone offset: $offsetString). "
        "Return ONLY a valid JSON array of events. Do not wrap in markdown or backticks. "
        "Each event JSON object must contain:\n"
        "- 'title': String\n"
        "- 'description': String\n"
        "- 'startTimeISO': String (Local time ISO 8601 string in the format YYYY-MM-DDTHH:mm:ss, without appending 'Z' or timezone offset)\n"
        "- 'endTimeISO': String (Local time ISO 8601 string in the format YYYY-MM-DDTHH:mm:ss, without appending 'Z' or timezone offset)\n"
        "Example response:\n"
        "[{\"title\": \"Study Machine Learning\", \"description\": \"Focus on Gradient Descent\", \"startTimeISO\": \"2026-06-22T19:00:00\", \"endTimeISO\": \"2026-06-22T21:00:00\"}]";

    final response = await model.generateContent([
      gemini.Content.text("$systemInstruction\n\nPrompt: $prompt")
    ]);

    final rawJson = response.text?.trim() ?? "[]";
    // Sanitize any markdown wrappers if generated by the LLM
    final sanitizedJson = rawJson.replaceAll('```json', '').replaceAll('```', '').trim();

    try {
      final List<dynamic> list = json.decode(sanitizedJson) as List<dynamic>;
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        final startStr = _sanitizeDateTimeString(map['startTimeISO'] as String? ?? '');
        final endStr = _sanitizeDateTimeString(map['endTimeISO'] as String? ?? '');
        return CalendarEvent(
          id: '',
          title: map['title'] as String? ?? 'Study Block',
          description: map['description'] as String? ?? '',
          startTime: DateTime.tryParse(startStr)?.toLocal() ?? now.add(const Duration(days: 1)),
          endTime: DateTime.tryParse(endStr)?.toLocal() ?? now.add(const Duration(days: 1, hours: 2)),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to parse Gemini schedule recommendation. Raw response: $sanitizedJson');
    }
  }

  String _sanitizeDateTimeString(String input) {
    var cleaned = input.trim();
    if (cleaned.endsWith('Z') || cleaned.endsWith('z')) {
      cleaned = cleaned.substring(0, cleaned.length - 1);
    }
    final offsetRegex = RegExp(r'[+-]\d{2}:?\d{2}$');
    cleaned = cleaned.replaceFirst(offsetRegex, '');
    return cleaned;
  }
}
