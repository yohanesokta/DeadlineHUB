# Authentication & Security Module (auth)

## Scopes
DeadlineAI requests the following OAuth 2.0 scopes from the user:
* `https://www.googleapis.com/auth/calendar` (Read, write, update, delete events)
* `https://www.googleapis.com/auth/drive.readonly` (Read and search user files)
* `https://www.googleapis.com/auth/gmail.readonly` (Read latest academic and critical emails)
* `https://www.googleapis.com/auth/classroom.courses.readonly` (Read classroom course names)
* `https://www.googleapis.com/auth/classroom.coursework.me.readonly` (Read student assignments and deadlines)

## Secure Storage Flow
1. User triggers Google Sign-in.
2. App opens authorization URI via system browser or loopback client.
3. OAuth response containing `access_token`, `refresh_token`, and token expiry is captured.
4. The tokens are encrypted using AES encryption and stored securely:
   * **Linux**: Secure storage via secret service DBus interface (via `flutter_secure_storage`).
   * **Windows**: DPAPI (Data Protection API).
   * **macOS**: Keychain.
5. On app launch, the app reads the cached credentials, verifies expiration, and uses the refresh token to get a new access token if necessary.

## API Interfaces

### Domain Layer: Repository
```dart
abstract class AuthRepository {
  Future<bool> signIn();
  Future<void> signOut();
  Future<String?> getAccessToken();
  Future<bool> isAuthenticated();
  Stream<bool> get authStateChanges;
}
```
