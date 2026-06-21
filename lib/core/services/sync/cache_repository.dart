import 'dart:convert';
import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:deadlinehub/core/database/database.dart';
import 'package:deadlinehub/features/calendar/domain/entities/calendar_event.dart';
import 'package:deadlinehub/features/drive/domain/entities/drive_file.dart';
import 'package:deadlinehub/features/classroom/domain/entities/classroom_assignment.dart';
import 'package:deadlinehub/features/email/domain/entities/academic_email.dart';

abstract class CacheRepository {
  Future<void> saveCalendarEvents(List<CalendarEvent> events);
  Future<List<CalendarEvent>> getCalendarEvents();

  Future<void> saveDriveFiles(List<DriveFile> files);
  Future<List<DriveFile>> getDriveFiles();

  Future<void> saveClassroomAssignments(List<ClassroomAssignment> assignments);
  Future<List<ClassroomAssignment>> getClassroomAssignments();

  Future<void> saveEmails(List<AcademicEmail> emails);
  Future<List<AcademicEmail>> getEmails();

  Future<void> clearAll();
}

class CacheRepositoryImpl implements CacheRepository {
  final AppDatabase _db;

  CacheRepositoryImpl(this._db);

  Future<File> _getCacheFile(String name) async {
    final folder = await getApplicationDocumentsDirectory();
    return File(p.join(folder.path, name));
  }

  @override
  Future<void> saveCalendarEvents(List<CalendarEvent> events) async {
    final file = await _getCacheFile('calendar_cache.json');
    final data = events.map((e) => {
      'id': e.id,
      'title': e.title,
      'description': e.description,
      'startTime': e.startTime.toIso8601String(),
      'endTime': e.endTime.toIso8601String(),
      'isAllDay': e.isAllDay,
      'recurrenceRule': e.recurrenceRule,
      'meetLink': e.meetLink,
    }).toList();
    await file.writeAsString(jsonEncode(data));
  }

  @override
  Future<List<CalendarEvent>> getCalendarEvents() async {
    try {
      final file = await _getCacheFile('calendar_cache.json');
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> list = jsonDecode(content);
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return CalendarEvent(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? '',
          description: map['description'] as String? ?? '',
          startTime: DateTime.tryParse(map['startTime'] as String? ?? '')?.toLocal() ?? DateTime.now(),
          endTime: DateTime.tryParse(map['endTime'] as String? ?? '')?.toLocal() ?? DateTime.now(),
          isAllDay: map['isAllDay'] as bool? ?? false,
          recurrenceRule: map['recurrenceRule'] as String?,
          meetLink: map['meetLink'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveDriveFiles(List<DriveFile> files) async {
    final file = await _getCacheFile('drive_cache.json');
    final data = files.map((f) => {
      'id': f.id,
      'name': f.name,
      'mimeType': f.mimeType,
      'webViewLink': f.webViewLink,
      'modifiedTime': f.modifiedTime.toIso8601String(),
      'thumbnailLink': f.thumbnailLink,
    }).toList();
    await file.writeAsString(jsonEncode(data));
  }

  @override
  Future<List<DriveFile>> getDriveFiles() async {
    try {
      final file = await _getCacheFile('drive_cache.json');
      if (!await file.exists()) return [];
      final content = await file.readAsString();
      final List<dynamic> list = jsonDecode(content);
      return list.map((item) {
        final map = item as Map<String, dynamic>;
        return DriveFile(
          id: map['id'] as String? ?? '',
          name: map['name'] as String? ?? '',
          mimeType: map['mimeType'] as String? ?? '',
          webViewLink: map['webViewLink'] as String? ?? '',
          modifiedTime: DateTime.tryParse(map['modifiedTime'] as String? ?? '')?.toLocal() ?? DateTime.now(),
          thumbnailLink: map['thumbnailLink'] as String?,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> saveClassroomAssignments(List<ClassroomAssignment> assignments) async {
    await _db.transaction(() async {
      await _db.delete(_db.cachedDeadlines).go();
      for (final assignment in assignments) {
        await _db.into(_db.cachedDeadlines).insertOnConflictUpdate(
          CachedDeadlinesCompanion.insert(
            id: assignment.id,
            courseName: assignment.courseName,
            title: assignment.title,
            description: Value(assignment.description),
            dueTime: Value(assignment.dueTime),
            alternateLink: assignment.alternateLink,
            isSubmitted: assignment.isSubmitted,
          ),
        );
      }
    });
  }

  @override
  Future<List<ClassroomAssignment>> getClassroomAssignments() async {
    final rows = await _db.select(_db.cachedDeadlines).get();
    return rows.map((row) => ClassroomAssignment(
      id: row.id,
      courseId: 'cached_course',
      courseName: row.courseName,
      title: row.title,
      description: row.description,
      dueTime: row.dueTime,
      alternateLink: row.alternateLink,
      isSubmitted: row.isSubmitted,
    )).toList();
  }

  @override
  Future<void> saveEmails(List<AcademicEmail> emails) async {
    await _db.transaction(() async {
      await _db.delete(_db.cachedEmails).go();
      for (final email in emails) {
        await _db.into(_db.cachedEmails).insertOnConflictUpdate(
          CachedEmailsCompanion.insert(
            id: email.id,
            sender: email.sender,
            subject: email.subject,
            snippet: email.snippet,
            bodySummary: Value(email.bodySummary),
            receivedAt: email.receivedAt,
            isAcademic: email.isAcademic,
          ),
        );
      }
    });
  }

  @override
  Future<List<AcademicEmail>> getEmails() async {
    final rows = await _db.select(_db.cachedEmails).get();
    return rows.map((row) => AcademicEmail(
      id: row.id,
      sender: row.sender,
      subject: row.subject,
      snippet: row.snippet,
      bodySummary: row.bodySummary,
      receivedAt: row.receivedAt,
      isAcademic: row.isAcademic,
    )).toList();
  }

  @override
  Future<void> clearAll() async {
    try {
      final calFile = await _getCacheFile('calendar_cache.json');
      if (await calFile.exists()) await calFile.delete();
      final drFile = await _getCacheFile('drive_cache.json');
      if (await drFile.exists()) await drFile.delete();
    } catch (_) {}
    await _db.delete(_db.cachedDeadlines).go();
    await _db.delete(_db.cachedEmails).go();
  }
}
