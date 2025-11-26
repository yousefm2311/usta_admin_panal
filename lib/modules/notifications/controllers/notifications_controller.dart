import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/notifications_service.dart';

class NotificationsController extends GetxController {
  final NotificationsService _service;
  NotificationsController({NotificationsService? service}) : _service = service ?? NotificationsService();

  final sending = false.obs;
  final loading = false.obs;
  final history = <dynamic>[].obs;
  final templates = <dynamic>[].obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadHistory();
    loadTemplates();
  }

  Future<void> loadHistory() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.history();
      final data = res.data;
      if (data is List) {
        history.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        history.assignAll(data['notifications'] ?? data['data'] ?? []);
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadTemplates() async {
    try {
      final res = await _service.templates();
      final data = res.data;
      if (data is List) {
        templates.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        templates.assignAll(data['templates'] ?? data['data'] ?? []);
      }
    } catch (_) {
      // Templates are optional; swallow errors to avoid blocking page.
    }
  }

  Future<void> createTemplate(Map<String, dynamic> payload) async {
    try {
      await _service.createTemplate(payload);
      await loadTemplates();
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> updateTemplate(String id, Map<String, dynamic> payload) async {
    try {
      await _service.updateTemplate(id, payload);
      await loadTemplates();
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> deleteTemplate(String id) async {
    try {
      await _service.deleteTemplate(id);
      await loadTemplates();
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> send({
    required String title,
    required String message,
    required String target,
  }) async {
    sending.value = true;
    try {
      await _service.send({'title': title, 'message': message, 'target': target.toLowerCase()});
      showSuccess('Success'.tr);
      await loadHistory();
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      sending.value = false;
    }
  }
}
