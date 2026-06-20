# Google Classroom Deadline Monitor (classroom)

## Overview
Monitors academic tasks, homeworks, and quizzes assigned to the user across their enrolled Google Classroom courses.

## Features
1. **Course & Work Fetching**: Fetches all courses and coursework (assignments) from Google Classroom.
2. **Sort & Prioritize**: Sorts assignments by due date (Urgency) and groups them by Course.
3. **Caching**: Caches the deadline details in SQLite using Drift to support offline reading and rapid loading.
4. **Study Planner Integration**: Connects with the calendar module, allowing the student to ask the AI to "plan a study schedule for my upcoming Machine Learning assignment".

## Repository Interface
```dart
abstract class ClassroomRepository {
  Future<List<ClassroomAssignment>> fetchAssignments({bool forceRefresh = false});
  Future<void> submitAssignment(String courseId, String courseWorkId, String submissionId);
}
```
