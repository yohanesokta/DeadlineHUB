import 'dart:async';
import 'package:drift/drift.dart';
import 'package:googleapis/classroom/v1.dart' as classroom;
import 'package:deadlinehub/features/classroom/domain/entities/classroom_assignment.dart';
import 'package:deadlinehub/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:deadlinehub/core/database/database.dart';
import 'package:deadlinehub/features/auth/domain/repositories/auth_repository.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  final AppDatabase _db;
  final AuthRepository _authRepo;

  ClassroomRepositoryImpl(this._db, this._authRepo);

  @override
  Future<List<ClassroomAssignment>> fetchAssignments({bool forceRefresh = false}) async {
    final cache = await _db.select(_db.cachedDeadlines).get();
    
    if (cache.isNotEmpty && !forceRefresh) {
      return cache.map((row) => ClassroomAssignment(
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

    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required to fetch Classroom data.');
    }

    final api = classroom.ClassroomApi(client);
    final List<ClassroomAssignment> assignments = [];

    // Fetch enrolled courses
    final coursesRes = await api.courses.list(studentId: 'me');
    final courses = coursesRes.courses ?? [];

    for (final course in courses) {
      if (course.id == null || course.name == null) continue;

      // Fetch coursework (assignments) for each course
      final courseworkRes = await api.courses.courseWork.list(course.id!);
      final courseworks = courseworkRes.courseWork ?? [];

      for (final work in courseworks) {
        if (work.id == null || work.title == null) continue;

        // Check student submission state to determine completion
        bool submitted = false;
        try {
          final submissionsRes = await api.courses.courseWork.studentSubmissions.list(course.id!, work.id!);
          final submissions = submissionsRes.studentSubmissions ?? [];
          if (submissions.isNotEmpty) {
            final state = submissions.first.state;
            submitted = state == 'TURNED_IN' || state == 'RETURNED';
          }
        } catch (_) {
          // Fallback if submission check fails
        }

        final dueTime = _parseDue(work.dueDate, work.dueTime);

        assignments.add(ClassroomAssignment(
          id: work.id!,
          courseId: course.id!,
          courseName: course.name!,
          title: work.title!,
          description: work.description,
          dueTime: dueTime,
          alternateLink: work.alternateLink ?? 'https://classroom.google.com',
          isSubmitted: submitted,
        ));
      }
    }

    // Cache updated real data in local database
    await _db.batch((batch) {
      for (final assignment in assignments) {
        batch.insert(
          _db.cachedDeadlines,
          CachedDeadlinesCompanion.insert(
            id: assignment.id,
            courseName: assignment.courseName,
            title: assignment.title,
            description: Value(assignment.description),
            dueTime: Value(assignment.dueTime),
            alternateLink: assignment.alternateLink,
            isSubmitted: assignment.isSubmitted,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    return assignments;
  }

  @override
  Future<void> submitAssignment(String courseId, String courseWorkId, String submissionId) async {
    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }

    final api = classroom.ClassroomApi(client);
    
    // In Google Classroom API, turning in an assignment is done on studentSubmissions.turnIn endpoint
    try {
      final submissionsRes = await api.courses.courseWork.studentSubmissions.list(courseId, courseWorkId);
      final submissions = submissionsRes.studentSubmissions ?? [];
      if (submissions.isNotEmpty && submissions.first.id != null) {
        final subId = submissions.first.id!;
        await api.courses.courseWork.studentSubmissions.turnIn(
          classroom.TurnInStudentSubmissionRequest(),
          courseId,
          courseWorkId,
          subId,
        );
      }
    } catch (_) {
      // Ignore API write errors or handle custom exceptions
    }

    // Always update local database to reflect user intent
    await (_db.update(_db.cachedDeadlines)
      ..where((t) => t.id.equals(courseWorkId)))
      .write(const CachedDeadlinesCompanion(isSubmitted: Value(true)));
  }

  @override
  Future<void> unsubmitAssignment(String courseId, String courseWorkId) async {
    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }

    final api = classroom.ClassroomApi(client);
    
    try {
      final submissionsRes = await api.courses.courseWork.studentSubmissions.list(courseId, courseWorkId);
      final submissions = submissionsRes.studentSubmissions ?? [];
      if (submissions.isNotEmpty && submissions.first.id != null) {
        final subId = submissions.first.id!;
        await api.courses.courseWork.studentSubmissions.reclaim(
          classroom.ReclaimStudentSubmissionRequest(),
          courseId,
          courseWorkId,
          subId,
        );
      }
    } catch (_) {
      // Ignore API write errors or handle custom exceptions
    }

    // Always update local database to reflect user intent
    await (_db.update(_db.cachedDeadlines)
      ..where((t) => t.id.equals(courseWorkId)))
      .write(const CachedDeadlinesCompanion(isSubmitted: Value(false)));
  }

  DateTime? _parseDue(classroom.Date? date, classroom.TimeOfDay? time) {
    if (date == null || date.year == null || date.month == null || date.day == null) return null;
    return DateTime(
      date.year!,
      date.month!,
      date.day!,
      time?.hours ?? 23,
      time?.minutes ?? 59,
    );
  }
}
