import 'package:get_storage/get_storage.dart';

class StorageService {
  StorageService();

  final GetStorage _box = GetStorage();

  T? read<T>(String key) => _box.read<T>(key);

  Future<void> write(String key, dynamic value) async {
    await _box.write(key, value);
  }

  Future<void> remove(String key) => _box.remove(key);
}
