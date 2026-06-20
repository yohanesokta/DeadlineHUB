import 'dart:async';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:deadlinehub/features/drive/domain/entities/drive_file.dart';
import 'package:deadlinehub/features/drive/domain/repositories/drive_repository.dart';
import 'package:deadlinehub/features/auth/domain/repositories/auth_repository.dart';

class DriveRepositoryImpl implements DriveRepository {
  final AuthRepository _authRepo;

  DriveRepositoryImpl(this._authRepo);

  @override
  Future<List<DriveFile>> fetchRecentFiles() async {
    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }

    final api = drive.DriveApi(client);
    final list = await api.files.list(
      pageSize: 15,
      orderBy: 'modifiedTime desc',
      q: 'trashed = false',
      $fields: 'files(id, name, mimeType, webViewLink, modifiedTime, thumbnailLink)',
    );

    final files = list.files ?? [];
    return files.map((f) => DriveFile(
      id: f.id ?? '',
      name: f.name ?? 'Untitled File',
      mimeType: f.mimeType ?? 'application/octet-stream',
      webViewLink: f.webViewLink ?? 'https://drive.google.com',
      modifiedTime: f.modifiedTime?.toLocal() ?? DateTime.now(),
      thumbnailLink: f.thumbnailLink,
    )).toList();
  }

  @override
  Future<List<DriveFile>> searchFiles(String query) async {
    final client = await _authRepo.getAuthClient();
    if (client == null) {
      throw Exception('Authentication required.');
    }

    final api = drive.DriveApi(client);
    
    // Construct search query
    final escapedQuery = query.replaceAll("'", "\\'");
    final qString = query.isEmpty 
        ? 'trashed = false' 
        : "name contains '$escapedQuery' and trashed = false";

    final list = await api.files.list(
      q: qString,
      $fields: 'files(id, name, mimeType, webViewLink, modifiedTime, thumbnailLink)',
    );

    final files = list.files ?? [];
    return files.map((f) => DriveFile(
      id: f.id ?? '',
      name: f.name ?? 'Untitled File',
      mimeType: f.mimeType ?? 'application/octet-stream',
      webViewLink: f.webViewLink ?? 'https://drive.google.com',
      modifiedTime: f.modifiedTime?.toLocal() ?? DateTime.now(),
      thumbnailLink: f.thumbnailLink,
    )).toList();
  }
}
