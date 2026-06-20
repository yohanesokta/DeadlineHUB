abstract class AuthRepository {
  Future<bool> signIn();
  Future<void> signOut();
  Future<String?> getAccessToken();
  Future<bool> isAuthenticated();
  Stream<bool> get authStateChanges;
}
