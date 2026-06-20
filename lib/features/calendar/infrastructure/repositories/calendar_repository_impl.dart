import 'dart:async';
import '../../domain/entities/calendar_event.dart';
import '../../domain/repositories/calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  final List<CalendarEvent> _mockEvents = [];

  CalendarRepositoryImpl() {
    _loadMockEvents();
  }

  void _loadMockEvents() {
    final now = DateTime.now();
    _mockEvents.addAll([
      CalendarEvent(
        id: 'cal_1',
        title: 'Machine Learning Lecture',
        description: 'Enrolled Course ML-402 in Room 301',
        startTime: DateTime(now.year, now.month, now.day, 10, 0),
        endTime: DateTime(now.year, now.month, now.day, 12, 0),
      ),
      CalendarEvent(
        id: 'cal_2',
        title: 'Linear Algebra Study Group',
        description: 'Discussing vector spaces and eigenvalues',
        startTime: DateTime(now.year, now.month, now.day + 1, 14, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 16, 0),
        meetLink: 'https://meet.google.com/abc-defg-hij',
      ),
      CalendarEvent(
        id: 'cal_3',
        title: 'Submit PKM Proposal Draft',
        description: 'Submission deadline for PKM project',
        startTime: DateTime(now.year, now.month, now.day + 2, 23, 59),
        endTime: DateTime(now.year, now.month, now.day + 2, 23, 59),
        isAllDay: true,
      ),
    ]);
  }

  @override
  Future<List<CalendarEvent>> fetchEvents({DateTime? start, DateTime? end}) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockEvents;
  }

  @override
  Future<CalendarEvent> createEvent(CalendarEvent event) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newEvent = event.copyWith(
      id: event.id.isEmpty ? 'cal_${DateTime.now().millisecondsSinceEpoch}' : event.id,
    );
    _mockEvents.add(newEvent);
    return newEvent;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockEvents.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<List<CalendarEvent>> generateScheduleFromPrompt(String prompt) async {
    // In production, this calls Gemini with structured output constraints.
    // We simulate the output of Gemini generating a schedule list of events.
    await Future.delayed(const Duration(seconds: 1));
    final now = DateTime.now();
    return [
      CalendarEvent(
        id: 'gen_${DateTime.now().millisecondsSinceEpoch}_1',
        title: 'Study: Machine Learning Fundamentals',
        description: 'System-generated block for: $prompt',
        startTime: DateTime(now.year, now.month, now.day + 1, 19, 0),
        endTime: DateTime(now.year, now.month, now.day + 1, 21, 0),
      ),
      CalendarEvent(
        id: 'gen_${DateTime.now().millisecondsSinceEpoch}_2',
        title: 'Study: Linear Algebra Exercises',
        description: 'System-generated block for: $prompt',
        startTime: DateTime(now.year, now.month, now.day + 2, 19, 0),
        endTime: DateTime(now.year, now.month, now.day + 2, 21, 0),
      ),
    ];
  }
}
