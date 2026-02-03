import 'package:get_storage/get_storage.dart';

class TokenStorage {
  static const _tokenKey = 'admin_token';
  static const _refreshKey = 'admin_refresh_token';
  static const _logoutKey = 'admin_logged_out';
  final GetStorage _box = GetStorage();

  String? get token {
    final logged = _box.read<bool>(_logoutKey) ?? false;
    if (logged) return null;
    return _box.read<String>(_tokenKey);
  }
  String? get refreshToken {
    final logged = _box.read<bool>(_logoutKey) ?? false;
    if (logged) return null;
    return _box.read<String>(_refreshKey);
  }

  bool get loggedOut => _box.read<bool>(_logoutKey) ?? false;

  Future<void> saveTokens(String token, {String? refreshToken}) async {
    await _box.write(_tokenKey, token);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      await _box.write(_refreshKey, refreshToken);
    } else {
      await _box.remove(_refreshKey); // ensure old refresh token cleared if backend didn't return one
    }
    await _box.write(_logoutKey, false);
  }

  Future<void> clear() async {
    // Remove only auth-related keys to avoid wiping unrelated app data.
    await _box.remove(_tokenKey);
    await _box.remove(_refreshKey);
    // Mark as logged out so startup won't try silent refresh/login.
    await _box.write(_logoutKey, true);
  }

  Future<void> markLoggedOut() async {
    await _box.write(_logoutKey, true);
  }
}
