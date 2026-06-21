import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/database.dart';
import '../services/secure_storage_service.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/infrastructure/repositories/auth_repository_impl.dart';
import '../../features/calendar/domain/repositories/calendar_repository.dart';
import '../../features/calendar/infrastructure/repositories/calendar_repository_impl.dart';
import '../../features/drive/domain/repositories/drive_repository.dart';
import '../../features/drive/infrastructure/repositories/drive_repository_impl.dart';
import '../../features/classroom/domain/repositories/classroom_repository.dart';
import '../../features/classroom/infrastructure/repositories/classroom_repository_impl.dart';
import '../../features/email/domain/repositories/email_repository.dart';
import '../../features/email/infrastructure/repositories/email_repository_impl.dart';
import '../../features/ai/domain/repositories/ai_repository.dart';
import '../../features/ai/infrastructure/repositories/ai_repository_impl.dart';
import '../services/sync/cache_repository.dart';
import '../services/sync/sync_status_repository.dart';
import '../services/sync/sync_coordinator.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthRepositoryImpl(storage);
});

final calendarRepositoryProvider = Provider<CalendarRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(secureStorageProvider);
  return CalendarRepositoryImpl(authRepo, storage);
});

final driveRepositoryProvider = Provider<DriveRepository>((ref) {
  final authRepo = ref.watch(authRepositoryProvider);
  return DriveRepositoryImpl(authRepo);
});

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  return ClassroomRepositoryImpl(db, authRepo);
});

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final authRepo = ref.watch(authRepositoryProvider);
  final storage = ref.watch(secureStorageProvider);
  return EmailRepositoryImpl(db, authRepo, storage);
});

final aiRepositoryProvider = Provider<AIRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final storage = ref.watch(secureStorageProvider);
  final calendarRepo = ref.watch(calendarRepositoryProvider);
  final driveRepo = ref.watch(driveRepositoryProvider);
  final classroomRepo = ref.watch(classroomRepositoryProvider);
  final emailRepo = ref.watch(emailRepositoryProvider);

  return AIRepositoryImpl(
    db: db,
    secureStorage: storage,
    calendarRepo: calendarRepo,
    driveRepo: driveRepo,
    classroomRepo: classroomRepo,
    emailRepo: emailRepo,
  );
});

final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return CacheRepositoryImpl(db);
});

final syncStatusRepositoryProvider = Provider<SyncStatusRepository>((ref) {
  return SyncStatusRepositoryImpl();
});

final syncCoordinatorProvider = Provider<SyncCoordinator>((ref) {
  final cache = ref.watch(cacheRepositoryProvider);
  final status = ref.watch(syncStatusRepositoryProvider);
  return SyncCoordinator(ref, cache, status);
});

class UserProfile {
  final String name;
  final String email;
  final String picture;

  const UserProfile({
    required this.name,
    required this.email,
    required this.picture,
  });
}

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final authRepo = ref.watch(authRepositoryProvider);
  // We check isAuthenticated first
  final isAuthed = await authRepo.isAuthenticated();
  if (!isAuthed) return null;
  final name = await authRepo.getUserName();
  final email = await authRepo.getUserEmail();
  final picture = await authRepo.getUserPicture();
  return UserProfile(
    name: name ?? '',
    email: email ?? '',
    picture: picture ?? '',
  );
});

final syncStatusProvider = StreamProvider<SyncStatusState>((ref) async* {
  final repo = ref.watch(syncStatusRepositoryProvider);
  yield repo.status;
  yield* repo.statusChanges;
});

final aiTaskEventsProvider = StreamProvider<List<AiTaskEvent>>((ref) {
  final aiRepo = ref.watch(aiRepositoryProvider);
  return aiRepo.taskEvents;
});
