import 'dart:async';
import 'package:deadlinehub/core/services/secure_storage_service.dart';
import 'package:deadlinehub/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageService _secureStorage;
  final _authStreamController = StreamController<bool>.broadcast();
  
  bool _isAuthenticated = false;
  String? _accessToken;

  AuthRepositoryImpl(this._secureStorage) {
    _init();
  }

  Future<void> _init() async {
    final token = await _secureStorage.getAccessToken();
    final expiry = await _secureStorage.getExpiry();
    
    if (token != null && expiry != null && expiry.isAfter(DateTime.now())) {
      _accessToken = token;
      _isAuthenticated = true;
      _authStreamController.add(true);
    } else {
      _isAuthenticated = false;
      _authStreamController.add(false);
    }
  }

  @override
  Future<bool> signIn() async {
    // Under a production environment, this integrates with google_sign_in
    // or initiates an OAuth loopback flow.
    // For local evaluation, we simulate successful sign-in with dummy token.
    _accessToken = "mock_google_oauth_access_token_12345";
    _isAuthenticated = true;
    
    await _secureStorage.saveAccessToken(_accessToken!);
    await _secureStorage.saveRefreshToken("mock_google_oauth_refresh_token_abcde");
    await _secureStorage.saveExpiry(DateTime.now().add(const Duration(hours: 24)));
    
    _authStreamController.add(true);
    return true;
  }

  @override
  Future<void> signOut() async {
    _accessToken = null;
    _isAuthenticated = false;
    await _secureStorage.clearAll();
    _authStreamController.add(false);
  }

  @override
  Future<String?> getAccessToken() async {
    if (_accessToken != null) return _accessToken;
    return await _secureStorage.getAccessToken();
  }

  @override
  Future<bool> isAuthenticated() async {
    return _isAuthenticated;
  }

  @override
  Stream<bool> get authStateChanges => _authStreamController.stream;
}
