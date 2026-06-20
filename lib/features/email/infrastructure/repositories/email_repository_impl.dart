import 'dart:async';
import 'package:drift/drift.dart';
import 'package:deadlinehub/features/email/domain/entities/academic_email.dart';
import 'package:deadlinehub/features/email/domain/repositories/email_repository.dart';
import 'package:deadlinehub/core/database/database.dart';

class EmailRepositoryImpl implements EmailRepository {
  final AppDatabase _db;

  EmailRepositoryImpl(this._db);

  @override
  Future<List<AcademicEmail>> fetchRecentEmails({bool forceRefresh = false}) async {
    final cache = await _db.select(_db.cachedEmails).get();

    if (cache.isNotEmpty && !forceRefresh) {
      return cache.map((row) => AcademicEmail(
        id: row.id,
        sender: row.sender,
        subject: row.subject,
        snippet: row.snippet,
        bodySummary: row.bodySummary,
        receivedAt: row.receivedAt,
        isAcademic: row.isAcademic,
      )).toList();
    }

    final now = DateTime.now();
    final mockEmails = [
      AcademicEmail(
        id: 'email_1',
        sender: 'Prof. John Doe <johndoe@university.edu>',
        subject: 'Report revision requested: ML Term Project',
        snippet: 'Please make sure to revise Section 3 and 4 of your ML paper before Tuesday.',
        bodySummary: 'Lecturer requested report revision before Tuesday.',
        receivedAt: now.subtract(const Duration(hours: 2)),
        isAcademic: true,
        isPriority: true,
      ),
      AcademicEmail(
        id: 'email_2',
        sender: 'Google Classroom <no-reply@classroom.google.com>',
        subject: 'New material: Inner Product Spaces in Linear Algebra',
        snippet: 'Dr. Smith posted a new material under Linear Algebra math_301.',
        bodySummary: 'New study material posted for Linear Algebra.',
        receivedAt: now.subtract(const Duration(hours: 5)),
        isAcademic: true,
        isPriority: false,
      ),
      AcademicEmail(
        id: 'email_3',
        sender: 'Student Office <admin@university.edu>',
        subject: 'Re-registration for upcoming semester',
        snippet: 'Important: Complete your registration payment before next month to remain enrolled.',
        bodySummary: 'Action needed: Complete payment for re-registration.',
        receivedAt: now.subtract(const Duration(days: 1)),
        isAcademic: true,
        isPriority: true,
      ),
      AcademicEmail(
        id: 'email_4',
        sender: 'Spotify <no-reply@spotify.com>',
        subject: 'Your weekly playlist update',
        snippet: 'Discover Weekly has new songs just for you. Listen now.',
        bodySummary: 'Spotify recommendation playlist.',
        receivedAt: now.subtract(const Duration(days: 2)),
        isAcademic: false,
        isPriority: false,
      ),
    ];

    await _db.batch((batch) {
      for (final email in mockEmails) {
        batch.insert(
          _db.cachedEmails,
          CachedEmailsCompanion.insert(
            id: email.id,
            sender: email.sender,
            subject: email.subject,
            snippet: email.snippet,
            bodySummary: Value(email.bodySummary),
            receivedAt: email.receivedAt,
            isAcademic: email.isAcademic,
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });

    return mockEmails;
  }

  @override
  Future<String> summarizeEmail(String emailBody) async {
    // In production, this runs a prompt against Gemini to summarize emailBody.
    await Future.delayed(const Duration(milliseconds: 500));
    return "Actionable summary: Please submit report revision requested before next Tuesday.";
  }
}
