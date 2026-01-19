import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/ai_service.dart';

class AIFraudController extends GetxController {
  final AIService _service;
  AIFraudController({AIService? service}) : _service = service ?? AIService();

  final cases = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.fraudDetection();
      final data = res.data;
      if (data is List) {
        cases.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        cases.assignAll(data['cases'] ?? data['items'] ?? data['data'] ?? []);
      } else {
        cases.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }
}
