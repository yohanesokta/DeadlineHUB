import '../entities/academic_email.dart';

abstract class EmailRepository {
  Future<List<AcademicEmail>> fetchRecentEmails({bool forceRefresh = false});
  Future<String> summarizeEmail(String emailBody);
}
