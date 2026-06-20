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
  return CalendarRepositoryImpl();
});

final driveRepositoryProvider = Provider<DriveRepository>((ref) {
  return DriveRepositoryImpl();
});

final classroomRepositoryProvider = Provider<ClassroomRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return ClassroomRepositoryImpl(db);
});

final emailRepositoryProvider = Provider<EmailRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return EmailRepositoryImpl(db);
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
