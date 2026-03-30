import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/complaints_service.dart';

class ComplaintsController extends GetxController {
  final ComplaintsService _service;
  ComplaintsController({ComplaintsService? service}) : _service = service ?? ComplaintsService();

  final complaints = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final status = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadComplaints();
  }

  Future<void> setStatus(String value) async {
    status.value = value;
    await loadComplaints();
  }

  Future<void> loadComplaints() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.list(status: status.value.isEmpty ? null : status.value);
      final data = res.data;
      if (data is List) {
        complaints.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        complaints.assignAll(data['complaints'] ?? data['data'] ?? []);
      } else {
        complaints.clear();
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
