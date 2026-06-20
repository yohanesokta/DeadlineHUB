import 'dart:async';
import 'package:drift/drift.dart';
import 'package:deadlinehub/features/classroom/domain/entities/classroom_assignment.dart';
import 'package:deadlinehub/features/classroom/domain/repositories/classroom_repository.dart';
import 'package:deadlinehub/core/database/database.dart';

class ClassroomRepositoryImpl implements ClassroomRepository {
  final AppDatabase _db;

  ClassroomRepositoryImpl(this._db);

  @override
  Future<List<ClassroomAssignment>> fetchAssignments({bool forceRefresh = false}) async {
    // 1. Fetch from local Drift database cache
    final cache = await _db.select(_db.cachedDeadlines).get();
    
    if (cache.isNotEmpty && !forceRefresh) {
      return cache.map((row) => ClassroomAssignment(
        id: row.id,
        courseId: 'mock_course',
        courseName: row.courseName,
        title: row.title,
        description: row.description,
        dueTime: row.dueTime,
        alternateLink: row.alternateLink,
        isSubmitted: row.isSubmitted,
      )).toList();
    }

    // 2. Local database cache is empty or forceRefresh is true: populate mock data
    final now = DateTime.now();
    final mockData = [
      ClassroomAssignment(
        id: 'class_ass_1',
        courseId: 'cs_402',
        courseName: 'Machine Learning',
        title: 'Assignment 1: Gradient Descent & Regularization',
        description: 'Implement Ridge and Lasso regression from scratch in Jupyter Notebook.',
        dueTime: now.add(const Duration(hours: 36)), // Within 48 hours!
        alternateLink: 'https://classroom.google.com/c/1',
        isSubmitted: false,
      ),
      ClassroomAssignment(
        id: 'class_ass_2',
        courseId: 'math_301',
        courseName: 'Linear Algebra',
        title: 'Problem Set 4: Vector Spaces & Inner Products',
        description: 'Complete questions 1-10 on page 142 of the textbook.',
        dueTime: now.add(const Duration(days: 3)),
        alternateLink: 'https://classroom.google.com/c/2',
        isSubmitted: false,
      ),
      ClassroomAssignment(
        id: 'class_ass_3',
        courseId: 'cs_412',
        courseName: 'Data Mining',
        title: 'Project Proposal: Association Rule Mining',
        description: 'Submit a 2-page PDF detailing your project objective and dataset.',
        dueTime: now.add(const Duration(days: 5)),
        alternateLink: 'https://classroom.google.com/c/3',
        isSubmitted: true,
      ),
      ClassroomAssignment(
        id: 'class_ass_4',
        courseId: 'pkm_101',
        courseName: 'PKM (Student Creativity)',
        title: 'Submit PKM Proposal Draft',
        description: 'Upload the draft proposal for review before submission to university.',
        dueTime: now.add(const Duration(hours: 47)), // Within 48 hours!
        alternateLink: 'https://classroom.google.com/c/4',
        isSubmitted: false,
      ),
    ];

    // Cache items into Drift DB
    await _db.batch((batch) {
      for (final assignment in mockData) {
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

    return mockData;
  }

  @override
  Future<void> submitAssignment(String courseId, String courseWorkId, String submissionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    // Update local database to mark as submitted
    await (_db.update(_db.cachedDeadlines)
      ..where((t) => t.id.equals(courseWorkId)))
      .write(const CachedDeadlinesCompanion(isSubmitted: Value(true)));
  }
}
