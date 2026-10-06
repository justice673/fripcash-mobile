import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persists bearer token + audience hint for cold start.
class TokenStore {
  TokenStore._();
  static final TokenStore instance = TokenStore._();

  static const _tokenKey = 'access_token';
  static const _audienceKey = 'auth_audience';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<String?> readAudience() => _storage.read(key: _audienceKey);

  Future<void> write({
    required String token,
    required String audience,
  }) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _audienceKey, value: audience);
  }

  Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _audienceKey);
  }
}

/// Audience values stored with the token.
abstract final class AuthAudience {
  static const consumer = 'CONSUMER';
  static const courier = 'COURIER';
}
