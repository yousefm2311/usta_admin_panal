import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/logs_service.dart';

class SystemHealthController extends GetxController {
  final LogsService _service;
  SystemHealthController({LogsService? service}) : _service = service ?? LogsService();

  final health = Rxn<Map<String, dynamic>>();
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
      final res = await _service.health();
      final data = res.data;
      health.value = data is Map<String, dynamic> ? (data['data'] ?? data) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }
}
