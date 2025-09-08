import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/auth/model/login_response.dart';

class TokenStorage {
  static const _tokenKey = 'auth_token';
  static const _roleKey  = 'user_role';
  static const _nameKey  = 'user_name';
  static const _emailKey = 'user_email';
  static final _storage  = const FlutterSecureStorage();

  static Future<void> saveLoginData(LoginResponse response) async {
    await _storage.write(key: _tokenKey, value: response.token);
    await _storage.write(key: _roleKey,  value: response.role);
    await _storage.write(key: _nameKey,  value: response.name);
    await _storage.write(key: _emailKey, value: response.email);
  }

  static Future<String?> getToken() => _storage.read(key: _tokenKey);
  static Future<String?> getRole()  => _storage.read(key: _roleKey);
  static Future<String?> getName()  => _storage.read(key: _nameKey);
  static Future<String?> getEmail() => _storage.read(key: _emailKey);

  static Future<void> clear() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _roleKey);
    await _storage.delete(key: _nameKey);
    await _storage.delete(key: _emailKey);
  }
}
