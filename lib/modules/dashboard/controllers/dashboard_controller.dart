import 'package:get/get.dart';

import '../services/dashboard_service.dart';

class DashboardController extends GetxController {
  final DashboardService _service;
  DashboardController({DashboardService? service}) : _service = service ?? DashboardService();

  final stats = Rxn<Map<String, dynamic>>();
  final activities = <dynamic>[].obs;
  final topArtisans = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    loading.value = true;
    error.value = null;
    try {
      stats.value = await _service.fetchStats();
      activities.assignAll(await _service.fetchActivities());
      topArtisans.assignAll(await _service.fetchTopArtisans());
    } catch (e) {
      error.value = e.toString();
    } finally {
      loading.value = false;
    }
  }
}
