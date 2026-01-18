import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/reports_service.dart';

class ReportDetailsController extends GetxController {
  final ReportsService _service;
  ReportDetailsController({ReportsService? service}) : _service = service ?? ReportsService();

  final report = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String id) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.details(id);
      final data = res.data;
      report.value = data is Map<String, dynamic> ? (data['report'] ?? data['data'] ?? data) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> reply(String id, String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _service.reply(id, text.trim());
      showSuccess('Success'.tr);
      await load(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> close(String id) async {
    try {
      await _service.close(id);
      showSuccess('Success'.tr);
      await load(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
