# Google Drive Quick Access (drive)

## Overview
Provides a quick interface to view and search files on Google Drive, particularly files that are relevant to current courses or modified recently.

## Features
1. **Recent Files Fetching**: Lists the top 15 most recently modified files.
2. **AI Recommendation**: Gemini analyses course deadlines and suggests relevant files currently in the student's Drive.
3. **Local Launching & Remote Opening**: Clicking a file opens it directly in the system's browser or through a default web handler.
4. **Keyword Search**: Quick local-remote query filtering.

## Repository Interface
```dart
abstract class DriveRepository {
  Future<List<DriveFile>> fetchRecentFiles();
  Future<List<DriveFile>> searchFiles(String query);
}
```
