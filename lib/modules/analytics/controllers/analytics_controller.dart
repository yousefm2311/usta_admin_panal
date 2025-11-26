import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/analytics_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _service;
  AnalyticsController({AnalyticsService? service}) : _service = service ?? AnalyticsService();

  final daily = <dynamic>[].obs;
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
      final res = await _service.daily();
      final data = res.data;
      daily.assignAll(data is List ? data : data['data'] ?? []);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }
}
