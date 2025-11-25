class StorageService {
   StorageService();

  // In a real app this would persist data. For this UI-only build we keep it in memory.
  final Map<String, dynamic> _cache = {};

  dynamic read(String key) => _cache[key];

  void write(String key, dynamic value) {
    _cache[key] = value;
  }
}
