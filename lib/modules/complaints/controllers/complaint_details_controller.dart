import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/complaints_service.dart';

class ComplaintDetailsController extends GetxController {
  final ComplaintsService _service;
  ComplaintDetailsController({ComplaintsService? service}) : _service = service ?? ComplaintsService();

  final complaint = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String id) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.details(id);
      final data = res.data;
      complaint.value = data is Map<String, dynamic> ? (data['complaint'] ?? data) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _service.updateStatus(id, status);
      showSuccess('Success'.tr);
      await load(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> addMessage(String id, String message) async {
    try {
      await _service.addMessage(id, {'message': message});
      await load(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
