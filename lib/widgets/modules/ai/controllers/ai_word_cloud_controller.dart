import 'package:get/get.dart';

import '../services/ai_service.dart';

class AIWordCloudController extends GetxController {
  final AIService _service;
  AIWordCloudController({AIService? service}) : _service = service ?? AIService();

  final wordCloud = <Map<String, dynamic>>[].obs;
  final loading = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    try {
      final res = await _service.wordCloud();
      final data = res.data;
      List<dynamic>? list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        list = data['data'] ?? data['words'];
      }
      if (list is List) {
        wordCloud.assignAll(list.map((e) => Map<String, dynamic>.from(e)).toList());
      } else {
        wordCloud.clear();
      }
    } catch (_) {
      wordCloud.clear();
    } finally {
      loading.value = false;
    }
  }
}
