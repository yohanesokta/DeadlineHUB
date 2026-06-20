import 'dart:async';
import '../../domain/entities/drive_file.dart';
import '../../domain/repositories/drive_repository.dart';

class DriveRepositoryImpl implements DriveRepository {
  final List<DriveFile> _mockFiles = [];

  DriveRepositoryImpl() {
    _loadMockFiles();
  }

  void _loadMockFiles() {
    final now = DateTime.now();
    _mockFiles.addAll([
      DriveFile(
        id: 'file_1',
        name: 'Machine Learning Assignment 1.ipynb',
        mimeType: 'application/x-ipynb+json',
        webViewLink: 'https://drive.google.com/file/d/1',
        modifiedTime: now.subtract(const Duration(hours: 3)),
      ),
      DriveFile(
        id: 'file_2',
        name: 'Linear Algebra Cheat Sheet.pdf',
        mimeType: 'application/pdf',
        webViewLink: 'https://drive.google.com/file/d/2',
        modifiedTime: now.subtract(const Duration(days: 1)),
      ),
      DriveFile(
        id: 'file_3',
        name: 'PKM Proposal Outline.docx',
        mimeType: 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
        webViewLink: 'https://drive.google.com/file/d/3',
        modifiedTime: now.subtract(const Duration(days: 2)),
      ),
      DriveFile(
        id: 'file_4',
        name: 'Data Mining Syllabus.pdf',
        mimeType: 'application/pdf',
        webViewLink: 'https://drive.google.com/file/d/4',
        modifiedTime: now.subtract(const Duration(days: 5)),
      ),
      DriveFile(
        id: 'file_5',
        name: 'Classroom Grades Spreadsheet.xlsx',
        mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        webViewLink: 'https://drive.google.com/file/d/5',
        modifiedTime: now.subtract(const Duration(days: 7)),
      ),
    ]);
  }

  @override
  Future<List<DriveFile>> fetchRecentFiles() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockFiles;
  }

  @override
  Future<List<DriveFile>> searchFiles(String query) async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (query.isEmpty) return _mockFiles;
    return _mockFiles.where((f) => f.name.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
