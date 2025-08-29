import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _roleKey  = 'user_role';
  static final _storage  = const FlutterSecureStorage();

  static Future<void> saveTokenAndRole(String token, String role) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _roleKey,  value: role);
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<String?> getRole()  => _storage.read(key: _roleKey);

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
  }
}
