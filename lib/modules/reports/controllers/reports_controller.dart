import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/reports_service.dart';

class ReportsController extends GetxController {
  final ReportsService _service;
  ReportsController({ReportsService? service}) : _service = service ?? ReportsService();

  final reports = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final filter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadReports();
  }

  Future<void> changeFilter(String value) async {
    filter.value = value;
    await loadReports(status: value);
  }

  Future<void> loadReports({String? status}) async {
    loading.value = true;
    error.value = null;
    try {
      final mapped = _mapStatus(status ?? filter.value);
      final res = mapped == null
          ? await _service.list()
          : await _service.filter({'status': mapped});
      final data = res.data;
      if (data is List) {
        reports.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        reports.assignAll(data['reports'] ?? data['data'] ?? []);
      } else {
        reports.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  String? _mapStatus(String value) {
    final normalized = value.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'all') return null;
    switch (normalized) {
      case 'open':
        return 'open';
      case 'in review':
      case 'in_review':
        return 'in_review';
      case 'closed':
        return 'closed';
      default:
        return normalized;
    }
  }
}
