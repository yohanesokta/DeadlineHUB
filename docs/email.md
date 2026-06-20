# Gmail Academic Email Dashboard (email)

## Overview
A specialized view that displays recent messages from Gmail, filtering and prioritizing academic emails (e.g. from professors, instructors, university domain, or Classroom notifications).

## Features
1. **Academic Spam Filtering**: Uses local heuristic rules and Gemini prompting to isolate important course updates.
2. **AI Email Summarization**: Provides a single-sentence or bullet-point summary of long emails, highlighting direct action items (e.g. "Submit draft by Tuesday").
3. **Priority Detection**: Marks emails requesting instant attention with a priority flag.

## Repository Interface
```dart
abstract class EmailRepository {
  Future<List<AcademicEmail>> fetchRecentEmails({bool forceRefresh = false});
  Future<String> summarizeEmail(String emailBody);
}
```
