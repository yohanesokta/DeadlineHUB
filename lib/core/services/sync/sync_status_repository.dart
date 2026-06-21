import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncState {
  idle,
  syncing,
  failed
}

class ModuleSyncStatus {
  final SyncState state;
  final DateTime? lastSynced;
  final String? error;

  const ModuleSyncStatus({
    this.state = SyncState.idle,
    this.lastSynced,
    this.error,
  });

  ModuleSyncStatus copyWith({
    SyncState? state,
    DateTime? lastSynced,
    String? error,
  }) {
    return ModuleSyncStatus(
      state: state ?? this.state,
      lastSynced: lastSynced ?? this.lastSynced,
      error: error,
    );
  }
}

class SyncStatusState {
  final ModuleSyncStatus calendar;
  final ModuleSyncStatus drive;
  final ModuleSyncStatus classroom;
  final ModuleSyncStatus gmail;

  const SyncStatusState({
    this.calendar = const ModuleSyncStatus(),
    this.drive = const ModuleSyncStatus(),
    this.classroom = const ModuleSyncStatus(),
    this.gmail = const ModuleSyncStatus(),
  });

  SyncStatusState copyWith({
    ModuleSyncStatus? calendar,
    ModuleSyncStatus? drive,
    ModuleSyncStatus? classroom,
    ModuleSyncStatus? gmail,
  }) {
    return SyncStatusState(
      calendar: calendar ?? this.calendar,
      drive: drive ?? this.drive,
      classroom: classroom ?? this.classroom,
      gmail: gmail ?? this.gmail,
    );
  }
}

abstract class SyncStatusRepository {
  SyncStatusState get status;
  Stream<SyncStatusState> get statusChanges;
  void updateStatus(String module, SyncState state, {DateTime? lastSynced, String? error});
}

class SyncStatusRepositoryImpl implements SyncStatusRepository {
  final _controller = StreamController<SyncStatusState>.broadcast();
  SyncStatusState _current = const SyncStatusState();

  @override
  SyncStatusState get status => _current;

  @override
  Stream<SyncStatusState> get statusChanges => _controller.stream;

  @override
  void updateStatus(String module, SyncState state, {DateTime? lastSynced, String? error}) {
    final currentModuleStatus = _getModuleStatus(module);
    final updatedModuleStatus = currentModuleStatus.copyWith(
      state: state,
      lastSynced: lastSynced ?? currentModuleStatus.lastSynced,
      error: error,
    );

    switch (module.toLowerCase()) {
      case 'calendar':
        _current = _current.copyWith(calendar: updatedModuleStatus);
        break;
      case 'drive':
        _current = _current.copyWith(drive: updatedModuleStatus);
        break;
      case 'classroom':
        _current = _current.copyWith(classroom: updatedModuleStatus);
        break;
      case 'gmail':
      case 'email':
        _current = _current.copyWith(gmail: updatedModuleStatus);
        break;
    }
    _controller.add(_current);
  }

  ModuleSyncStatus _getModuleStatus(String module) {
    switch (module.toLowerCase()) {
      case 'calendar':
        return _current.calendar;
      case 'drive':
        return _current.drive;
      case 'classroom':
        return _current.classroom;
      case 'gmail':
      case 'email':
        return _current.gmail;
      default:
        return const ModuleSyncStatus();
    }
  }
}
