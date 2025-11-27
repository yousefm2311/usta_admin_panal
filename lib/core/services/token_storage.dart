import 'package:get_storage/get_storage.dart';

class TokenStorage {
  static const _tokenKey = 'admin_token';
  static const _refreshKey = 'admin_refresh_token';
  static const _logoutKey = 'admin_logged_out';
  final GetStorage _box = GetStorage();

  String? get token => _box.read<String>(_tokenKey);
  String? get refreshToken => _box.read<String>(_refreshKey);
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
    await _box.erase(); // wipe all persisted keys to avoid stale tokens
    await _box.write(_logoutKey, true); // explicitly mark logged out
  }
}
