import '../entities/calendar_event.dart';

abstract class CalendarRepository {
  Future<List<CalendarEvent>> fetchEvents({DateTime? start, DateTime? end});
  Future<CalendarEvent> createEvent(CalendarEvent event);
  Future<void> deleteEvent(String eventId);
  Future<CalendarEvent> updateEvent(CalendarEvent event);
  Future<List<CalendarEvent>> generateScheduleFromPrompt(String prompt);
}
