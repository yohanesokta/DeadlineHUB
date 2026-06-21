import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:deadlinehub/core/providers/providers.dart';
import 'package:deadlinehub/core/services/sync/cache_repository.dart';
import 'package:deadlinehub/core/services/sync/sync_status_repository.dart';

class SyncCoordinator {
  final Ref _ref;
  final CacheRepository _cacheRepo;
  final SyncStatusRepository _statusRepo;
  Timer? _syncTimer;

  SyncCoordinator(this._ref, this._cacheRepo, this._statusRepo);

  void startPeriodicSync() {
    _syncTimer?.cancel();
    syncAll();
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (_) => syncAll());
  }

  void stopPeriodicSync() {
    _syncTimer?.cancel();
  }

  Future<void> syncAll() async {
    await Future.wait([
      syncCalendar(),
      syncDrive(),
      syncClassroom(),
      syncGmail(),
    ]);
  }

  Future<void> syncCalendar() async {
    _statusRepo.updateStatus('calendar', SyncState.syncing);
    try {
      final repo = _ref.read(calendarRepositoryProvider);
      final events = await repo.fetchEvents();
      await _cacheRepo.saveCalendarEvents(events);
      _statusRepo.updateStatus('calendar', SyncState.idle, lastSynced: DateTime.now());
    } catch (e) {
      _statusRepo.updateStatus('calendar', SyncState.failed, error: e.toString());
    }
  }

  Future<void> syncDrive() async {
    _statusRepo.updateStatus('drive', SyncState.syncing);
    try {
      final repo = _ref.read(driveRepositoryProvider);
      final files = await repo.fetchRecentFiles();
      await _cacheRepo.saveDriveFiles(files);
      _statusRepo.updateStatus('drive', SyncState.idle, lastSynced: DateTime.now());
    } catch (e) {
      _statusRepo.updateStatus('drive', SyncState.failed, error: e.toString());
    }
  }

  Future<void> syncClassroom() async {
    _statusRepo.updateStatus('classroom', SyncState.syncing);
    try {
      final repo = _ref.read(classroomRepositoryProvider);
      final assignments = await repo.fetchAssignments(forceRefresh: true);
      await _cacheRepo.saveClassroomAssignments(assignments);
      _statusRepo.updateStatus('classroom', SyncState.idle, lastSynced: DateTime.now());
    } catch (e) {
      _statusRepo.updateStatus('classroom', SyncState.failed, error: e.toString());
    }
  }

  Future<void> syncGmail() async {
    _statusRepo.updateStatus('gmail', SyncState.syncing);
    try {
      final repo = _ref.read(emailRepositoryProvider);
      final emails = await repo.fetchRecentEmails(forceRefresh: true);
      await _cacheRepo.saveEmails(emails);
      _statusRepo.updateStatus('gmail', SyncState.idle, lastSynced: DateTime.now());
    } catch (e) {
      _statusRepo.updateStatus('gmail', SyncState.failed, error: e.toString());
    }
  }
}
