import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:deadlinehub/core/services/secure_storage_service.dart';
import 'package:deadlinehub/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final SecureStorageService _secureStorage;
  final _authStreamController = StreamController<bool>.broadcast();
  AuthClient? _cachedClient;

  AuthRepositoryImpl(this._secureStorage) {
    _init();
  }

  String get _googleClientId {
    return Platform.environment['GOOGLE_CLIENT_ID'] ?? const String.fromEnvironment('GOOGLE_CLIENT_ID');
  }

  String get _googleClientSecret {
    return Platform.environment['GOOGLE_CLIENT_SECRET'] ?? const String.fromEnvironment('GOOGLE_CLIENT_SECRET');
  }

  Future<void> _init() async {
    final client = await getAuthClient();
    if (client != null) {
      _fetchAndSaveUserProfile(client.credentials.accessToken.data);
      _authStreamController.add(true);
    } else {
      _authStreamController.add(false);
    }
  }

  @override
  Future<bool> signIn() async {
    final clientId = _googleClientId.trim();
    final clientSecret = _googleClientSecret.trim();

    if (clientId.isEmpty || clientSecret.isEmpty) {
      throw Exception(
        'Developer Error: Developer credentials GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET are not configured in the host environment.'
      );
    }

    final scopes = [
      'https://www.googleapis.com/auth/calendar',
      'https://www.googleapis.com/auth/drive.readonly',
      'https://www.googleapis.com/auth/gmail.readonly',
      'https://www.googleapis.com/auth/classroom.courses.readonly',
      'https://www.googleapis.com/auth/classroom.coursework.me.readonly',
      'openid',
      'email',
      'profile'
    ];

    try {
      final googleClientId = ClientId(clientId, clientSecret);
      
      final client = await clientViaUserConsent(googleClientId, scopes, (url) async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        } else {
          throw Exception('Could not launch browser consent page: $url');
        }
      });

      _cachedClient = client;

      // Save credentials in Secure Storage
      await _secureStorage.saveAccessToken(client.credentials.accessToken.data);
      if (client.credentials.refreshToken != null) {
        await _secureStorage.saveRefreshToken(client.credentials.refreshToken!);
      }
      await _secureStorage.saveExpiry(client.credentials.accessToken.expiry);

      // Fetch user profile immediately
      await _fetchAndSaveUserProfile(client.credentials.accessToken.data);

      client.credentialUpdates.listen((creds) async {
        await _secureStorage.saveAccessToken(creds.accessToken.data);
        await _secureStorage.saveExpiry(creds.accessToken.expiry);
        await _fetchAndSaveUserProfile(creds.accessToken.data);
      });

      _authStreamController.add(true);
      return true;
    } catch (e) {
      _authStreamController.add(false);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    _cachedClient?.close();
    _cachedClient = null;
    await _secureStorage.clearAll();
    _authStreamController.add(false);
  }

  @override
  Future<String?> getAccessToken() async {
    final client = await getAuthClient();
    return client?.credentials.accessToken.data;
  }

  @override
  Future<bool> isAuthenticated() async {
    final client = await getAuthClient();
    return client != null;
  }

  @override
  Stream<bool> get authStateChanges => _authStreamController.stream;

  @override
  Future<AuthClient?> getAuthClient() async {
    if (_cachedClient != null) return _cachedClient;

    final clientIdStr = _googleClientId.trim();
    final clientSecretStr = _googleClientSecret.trim();
    final accessTokenStr = await _secureStorage.getAccessToken();
    final refreshTokenStr = await _secureStorage.getRefreshToken();
    final expiry = await _secureStorage.getExpiry();

    if (clientIdStr.isEmpty || clientSecretStr.isEmpty || accessTokenStr == null || refreshTokenStr == null || expiry == null) {
      return null;
    }

    final clientId = ClientId(clientIdStr, clientSecretStr);
    final credentials = AccessCredentials(
      AccessToken('Bearer', accessTokenStr, expiry),
      refreshTokenStr,
      [
        'https://www.googleapis.com/auth/calendar',
        'https://www.googleapis.com/auth/drive.readonly',
        'https://www.googleapis.com/auth/gmail.readonly',
        'https://www.googleapis.com/auth/classroom.courses.readonly',
        'https://www.googleapis.com/auth/classroom.coursework.me.readonly',
      ],
    );

    final client = autoRefreshingClient(clientId, credentials, http.Client());
    
    client.credentialUpdates.listen((creds) async {
      await _secureStorage.saveAccessToken(creds.accessToken.data);
      await _secureStorage.saveExpiry(creds.accessToken.expiry);
      await _fetchAndSaveUserProfile(creds.accessToken.data);
    });

    _cachedClient = client;
    return client;
  }

  Future<void> _fetchAndSaveUserProfile(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('https://www.googleapis.com/oauth2/v3/userinfo'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['name'] as String? ?? '';
        final email = data['email'] as String? ?? '';
        final picture = data['picture'] as String? ?? '';
        await _secureStorage.saveUserName(name);
        await _secureStorage.saveUserEmail(email);
        await _secureStorage.saveUserPicture(picture);
      } else {
        debugPrint('Failed to fetch user info: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    }
  }

  @override
  Future<String?> getUserName() async {
    return await _secureStorage.getUserName();
  }

  @override
  Future<String?> getUserEmail() async {
    return await _secureStorage.getUserEmail();
  }

  @override
  Future<String?> getUserPicture() async {
    return await _secureStorage.getUserPicture();
  }

  @override
  Future<void> refreshProfile() async {
    final token = await getAccessToken();
    if (token != null) {
      await _fetchAndSaveUserProfile(token);
    }
  }
}
