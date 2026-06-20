import 'dart:async';
import 'package:drift/drift.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:google_generative_ai/google_generative_ai.dart' as gemini;
import 'package:deadlinehub/core/database/database.dart';
import 'package:deadlinehub/core/services/secure_storage_service.dart';
import 'package:deadlinehub/features/auth/domain/repositories/auth_repository.dart';
import 'package:deadlinehub/features/email/domain/entities/academic_email.dart';
import 'package:deadlinehub/features/email/domain/repositories/email_repository.dart';

class EmailRepositoryImpl implements EmailRepository {
  final AppDatabase _db;
  final AuthRepository _authRepo;
  final SecureStorageService _secureStorage;

  EmailRepositoryImpl(this._db, this._authRepo, this._secureStorage);

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

    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }

    final api = gmail.GmailApi(client);
    final listRes = await api.users.messages.list('me', maxResults: 15, q: 'label:INBOX');
    final messageStubs = listRes.messages ?? [];

    final List<AcademicEmail> emails = [];

    for (final stub in messageStubs) {
      if (stub.id == null) continue;

      try {
        final detail = await api.users.messages.get('me', stub.id!);
        
        final headers = detail.payload?.headers ?? [];
        String from = 'Unknown Sender';
        String subject = 'No Subject';
        DateTime date = DateTime.now();

        for (final header in headers) {
          if (header.name == 'From') {
            from = header.value ?? from;
          } else if (header.name == 'Subject') {
            subject = header.value ?? subject;
          } else if (header.name == 'Date') {
            final parsedDate = DateTime.tryParse(header.value ?? '');
            if (parsedDate != null) date = parsedDate;
          }
        }

        final snippet = detail.snippet ?? '';
        final isAcademic = _checkIfAcademic(from, subject, snippet);

        emails.add(AcademicEmail(
          id: stub.id!,
          sender: from,
          subject: subject,
          snippet: snippet,
          receivedAt: date.toLocal(),
          isAcademic: isAcademic,
          isPriority: isAcademic && (snippet.toLowerCase().contains('important') || snippet.toLowerCase().contains('urg') || subject.toLowerCase().contains('revis')),
        ));
      } catch (_) {
        // Continue if fetching single email details fails
      }
    }

    // Cache to Drift Database
    await _db.batch((batch) {
      for (final email in emails) {
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

    return emails;
  }

  @override
  Future<String> summarizeEmail(String emailBody) async {
    final apiKey = await _secureStorage.getGeminiApiKey();
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('Gemini API Key missing.');
    }

    final modelName = await _secureStorage.getGeminiModel() ?? 'models/gemini-2.0-flash';
    final model = gemini.GenerativeModel(
      model: modelName,
      apiKey: apiKey,
    );

    final prompt = 
        "Summarize this email in a single concise sentence. "
        "Highlight any direct actionable items or deadlines for the student:\n\n$emailBody";

    final response = await model.generateContent([gemini.Content.text(prompt)]);
    return response.text?.trim() ?? "Failed to summarize email content.";
  }

  bool _checkIfAcademic(String from, String subject, String snippet) {
    final searchArea = '$from $subject $snippet'.toLowerCase();
    
    // Heuristics for academic emails
    final isAcademicDomain = from.toLowerCase().contains('.edu') || from.toLowerCase().contains('ac.id');
    final containsAcademicKeywords = searchArea.contains('classroom') ||
        searchArea.contains('lecturer') ||
        searchArea.contains('professor') ||
        searchArea.contains('assignment') ||
        searchArea.contains('exam') ||
        searchArea.contains('syllabus') ||
        searchArea.contains('tugas') ||
        searchArea.contains('dosen') ||
        searchArea.contains('kuliah');

    return isAcademicDomain || containsAcademicKeywords;
  }
}
