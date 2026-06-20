import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:deadlinehub/core/providers/providers.dart';

enum IntegrationStatusState {
  connected,
  failed,
  permissionMissing,
  loading,
}

class IntegrationStatus {
  final IntegrationStatusState google;
  final IntegrationStatusState gemini;
  final IntegrationStatusState calendar;
  final IntegrationStatusState drive;
  final IntegrationStatusState classroom;
  final IntegrationStatusState gmail;

  final String? googleError;
  final String? geminiError;
  final String? calendarError;
  final String? driveError;
  final String? classroomError;
  final String? gmailError;

  const IntegrationStatus({
    this.google = IntegrationStatusState.loading,
    this.gemini = IntegrationStatusState.loading,
    this.calendar = IntegrationStatusState.loading,
    this.drive = IntegrationStatusState.loading,
    this.classroom = IntegrationStatusState.loading,
    this.gmail = IntegrationStatusState.loading,
    this.googleError,
    this.geminiError,
    this.calendarError,
    this.driveError,
    this.classroomError,
    this.gmailError,
  });

  IntegrationStatus copyWith({
    IntegrationStatusState? google,
    IntegrationStatusState? gemini,
    IntegrationStatusState? calendar,
    IntegrationStatusState? drive,
    IntegrationStatusState? classroom,
    IntegrationStatusState? gmail,
    String? googleError,
    String? geminiError,
    String? calendarError,
    String? driveError,
    String? classroomError,
    String? gmailError,
  }) {
    return IntegrationStatus(
      google: google ?? this.google,
      gemini: gemini ?? this.gemini,
      calendar: calendar ?? this.calendar,
      drive: drive ?? this.drive,
      classroom: classroom ?? this.classroom,
      gmail: gmail ?? this.gmail,
      googleError: googleError ?? this.googleError,
      geminiError: geminiError ?? this.geminiError,
      calendarError: calendarError ?? this.calendarError,
      driveError: driveError ?? this.driveError,
      classroomError: classroomError ?? this.classroomError,
      gmailError: gmailError ?? this.gmailError,
    );
  }
}

class IntegrationStatusNotifier extends Notifier<IntegrationStatus> {
  @override
  IntegrationStatus build() {
    // Listen to authentication changes from AuthRepository
    final authStream = ref.watch(authRepositoryProvider).authStateChanges;
    final subscription = authStream.listen((isAuthenticated) {
      refreshStatus();
    });
    ref.onDispose(() {
      subscription.cancel();
    });

    Future.microtask(() => refreshStatus());
    return const IntegrationStatus();
  }

  Future<void> refreshStatus() async {
    state = const IntegrationStatus(); // Reset to loading states

    final authRepo = ref.read(authRepositoryProvider);
    final secureStorage = ref.read(secureStorageProvider);

    // 1. Google
    final googleAuthed = await authRepo.isAuthenticated();
    final googleState = googleAuthed ? IntegrationStatusState.connected : IntegrationStatusState.failed;
    state = state.copyWith(google: googleState, googleError: googleAuthed ? null : 'Google Authentication invalid');

    // 2. Gemini
    final geminiKey = await secureStorage.getGeminiApiKey();
    IntegrationStatusState geminiState = IntegrationStatusState.loading;
    String? geminiError;
    if (geminiKey == null || geminiKey.isEmpty) {
      geminiState = IntegrationStatusState.failed;
      geminiError = 'Gemini API Key missing';
    } else {
      final valid = await _validateGeminiKey(geminiKey);
      geminiState = valid ? IntegrationStatusState.connected : IntegrationStatusState.failed;
      geminiError = valid ? null : 'Invalid Gemini API Key';
    }
    state = state.copyWith(gemini: geminiState, geminiError: geminiError);

    if (!googleAuthed) {
      // If Google authentication is missing, Google dependent APIs will fail immediately
      state = state.copyWith(
        calendar: IntegrationStatusState.failed,
        calendarError: 'Google login required',
        drive: IntegrationStatusState.failed,
        driveError: 'Google login required',
        classroom: IntegrationStatusState.failed,
        classroomError: 'Google login required',
        gmail: IntegrationStatusState.failed,
        gmailError: 'Google login required',
      );
      return;
    }

    // 3. Calendar
    try {
      await ref.read(calendarRepositoryProvider).fetchEvents();
      state = state.copyWith(calendar: IntegrationStatusState.connected, calendarError: null);
    } catch (e) {
      state = state.copyWith(
        calendar: _determineErrorState(e),
        calendarError: e.toString(),
      );
    }

    // 4. Drive
    try {
      await ref.read(driveRepositoryProvider).fetchRecentFiles();
      state = state.copyWith(drive: IntegrationStatusState.connected, driveError: null);
    } catch (e) {
      state = state.copyWith(
        drive: _determineErrorState(e),
        driveError: e.toString(),
      );
    }

    // 5. Classroom
    try {
      await ref.read(classroomRepositoryProvider).fetchAssignments();
      state = state.copyWith(classroom: IntegrationStatusState.connected, classroomError: null);
    } catch (e) {
      state = state.copyWith(
        classroom: _determineErrorState(e),
        classroomError: e.toString(),
      );
    }

    // 6. Gmail
    try {
      await ref.read(emailRepositoryProvider).fetchRecentEmails();
      state = state.copyWith(gmail: IntegrationStatusState.connected, gmailError: null);
    } catch (e) {
      state = state.copyWith(
        gmail: _determineErrorState(e),
        gmailError: e.toString(),
      );
    }
  }

  IntegrationStatusState _determineErrorState(Object e) {
    final errStr = e.toString().toLowerCase();
    if (errStr.contains('403') || errStr.contains('permission') || errStr.contains('insufficient')) {
      return IntegrationStatusState.permissionMissing;
    }
    return IntegrationStatusState.failed;
  }

  Future<bool> _validateGeminiKey(String apiKey) async {
    try {
      final model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: apiKey,
      );
      final response = await model.generateContent([Content.text('Hello')]);
      return response.text != null;
    } catch (_) {
      return false;
    }
  }

  void updateCalendarStatus(IntegrationStatusState status, String? error) {
    state = state.copyWith(calendar: status, calendarError: error);
  }

  void updateDriveStatus(IntegrationStatusState status, String? error) {
    state = state.copyWith(drive: status, driveError: error);
  }

  void updateGmailStatus(IntegrationStatusState status, String? error) {
    state = state.copyWith(gmail: status, gmailError: error);
  }

  void updateClassroomStatus(IntegrationStatusState status, String? error) {
    state = state.copyWith(classroom: status, classroomError: error);
  }
}

final integrationStatusProvider = NotifierProvider<IntegrationStatusNotifier, IntegrationStatus>(IntegrationStatusNotifier.new);
