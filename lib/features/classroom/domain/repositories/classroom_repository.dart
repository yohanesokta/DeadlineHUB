import '../entities/classroom_assignment.dart';

abstract class ClassroomRepository {
  Future<List<ClassroomAssignment>> fetchAssignments({bool forceRefresh = false});
  Future<void> submitAssignment(String courseId, String courseWorkId, String submissionId);
  Future<void> unsubmitAssignment(String courseId, String courseWorkId);
}
