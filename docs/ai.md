# Gemini AI Agent System (ai)

## Overview
The AI module encapsulates the conversational chat and the background agent execution loop. It integrates with other modules via a **Gemini Tool-Calling Architecture**.

## Tools Available to Gemini
The AI engine is equipped with the following tool definitions (`FunctionDeclaration` inside `package:google_generative_ai`):

1. **`list_classroom_deadlines`**: Retrieves upcoming Google Classroom coursework.
2. **`create_calendar_event`**: Creates calendar blocks/study sessions.
3. **`list_recent_emails`**: Reads and queries recent Gmail logs.
4. **`search_google_drive`**: Searches for notes/materials on Google Drive.
5. **`schedule_google_meet`**: Creates a calendar event with a Google Meet attachment.

## Workflow
1. User submits a request (e.g. "Create a meeting for my group project").
2. Gemini responds with a tool call request for `schedule_google_meet`.
3. The application intercepts the tool call, executes the logic using the Google API repository, and passes back the result (the generated link and event time).
4. Gemini summarizes the results in a friendly chat message.

## Repository Interface
```dart
abstract class AIRepository {
  Future<String> chat(String message);
  Stream<String> chatStream(String message);
  Future<void> clearHistory();
}
```
