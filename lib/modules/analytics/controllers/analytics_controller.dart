import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/analytics_service.dart';

class AnalyticsController extends GetxController {
  final AnalyticsService _service;
  AnalyticsController({AnalyticsService? service}) : _service = service ?? AnalyticsService();

  final daily = <dynamic>[].obs;
  final revenue = Rxn<Map<String, dynamic>>();
  final activeUsers = Rxn<Map<String, dynamic>>();
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
    }
    try {
      final res = await _service.revenue();
      final data = res.data;
      revenue.value = _asMap(data);
    } catch (_) {
      revenue.value = null;
    }
    try {
      final res = await _service.activeUsers();
      final data = res.data;
      activeUsers.value = _asMap(data);
    } catch (_) {
      activeUsers.value = null;
    } finally {
      loading.value = false;
    }
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['data'] is Map<String, dynamic> ? data['data'] as Map<String, dynamic> : data;
    }
    return null;
  }
}
