# Google Calendar Sync & Planner (calendar)

## Overview
The Calendar module provides a dedicated UI to view the current schedule and a smart calendar scheduler helper.

## Features
1. **Interactive Event Planner**: Users describe a plan naturally, e.g. "Allocate 2 hours of study for ML every evening for the next 2 weeks."
2. **AI Schedule Generator**: Under the hood, the prompt is parsed by Gemini which outputs a structured JSON list of calendar events containing:
   * Title
   * Start Date/Time
   * End Date/Time
   * Recurrence rules (RRule format)
3. **Draft Preview**: The generated list is presented in the UI as draft items. The user can edit or delete items before committing.
4. **Google Calendar Sync**: Upon user confirmation, events are created in the user's primary Google Calendar via the Google Calendar API.

## Repository Interface
```dart
abstract class CalendarRepository {
  Future<List<CalendarEvent>> fetchEvents({DateTime? start, DateTime? end});
  Future<CalendarEvent> createEvent(CalendarEvent event);
  Future<void> deleteEvent(String eventId);
  Future<List<CalendarEvent>> generateScheduleFromPrompt(String prompt);
}
```
