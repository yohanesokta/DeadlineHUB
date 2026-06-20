import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  final _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'google_oauth_access_token';
  static const String _refreshTokenKey = 'google_oauth_refresh_token';
  static const String _expiryKey = 'google_oauth_expiry';
  static const String _geminiApiKey = 'gemini_api_key';

  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> saveExpiry(DateTime expiry) async {
    await _storage.write(key: _expiryKey, value: expiry.toIso8601String());
  }

  Future<DateTime?> getExpiry() async {
    final val = await _storage.read(key: _expiryKey);
    if (val == null) return null;
    return DateTime.tryParse(val);
  }

  Future<void> saveGeminiApiKey(String key) async {
    await _storage.write(key: _geminiApiKey, value: key);
  }

  Future<String?> getGeminiApiKey() async {
    return await _storage.read(key: _geminiApiKey);
  }

  Future<void> clearAll() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _expiryKey);
    await _storage.delete(key: _geminiApiKey);
  }
}
