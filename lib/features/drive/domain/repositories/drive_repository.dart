import '../entities/drive_file.dart';

abstract class DriveRepository {
  Future<List<DriveFile>> fetchRecentFiles();
  Future<List<DriveFile>> searchFiles(String query);
}
