import 'package:get_storage/get_storage.dart';

class TokenStorage {
  static const _tokenKey = 'admin_token';
  final GetStorage _box = GetStorage();

  String? get token => _box.read<String>(_tokenKey);

  Future<void> saveToken(String token) async {
    await _box.write(_tokenKey, token);
  }

  Future<void> clear() async {
    await _box.remove(_tokenKey);
  }
}
