import 'package:googleapis_auth/googleapis_auth.dart';

abstract class AuthRepository {
  Future<bool> signIn();
  Future<void> signOut();
  Future<String?> getAccessToken();
  Future<bool> isAuthenticated();
  Stream<bool> get authStateChanges;
  Future<AuthClient?> getAuthClient();
}
