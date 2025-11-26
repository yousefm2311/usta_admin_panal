import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/logs_service.dart';

class ActivityLogsController extends GetxController {
  final LogsService _service;
  ActivityLogsController({LogsService? service}) : _service = service ?? LogsService();

  final logs = <dynamic>[].obs;
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
      final res = await _service.activity();
      final data = res.data;
      if (data is List) {
        logs.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        logs.assignAll(data['data'] ?? data['logs'] ?? []);
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
