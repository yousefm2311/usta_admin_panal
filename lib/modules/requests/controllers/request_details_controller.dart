import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/requests_service.dart';

class RequestDetailsController extends GetxController {
  final RequestsService _service;
  RequestDetailsController({RequestsService? service}) : _service = service ?? RequestsService();

  final request = Rxn<Map<String, dynamic>>();
  final timeline = <dynamic>[].obs;
  final messages = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String id) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.fetchDetails(id);
      final data = res.data;
      request.value = data is Map<String, dynamic> ? (data['request'] ?? data['data'] ?? data) : null;

      final timelineRes = await _service.timeline(id);
      final t = timelineRes.data;
      if (t is List) {
        timeline.assignAll(t);
      } else if (t is Map<String, dynamic>) {
        timeline.assignAll(t['timeline'] ?? t['data'] ?? []);
      }

      try {
        final msgRes = await _service.messages(id);
        final mData = msgRes.data;
        if (mData is List) {
          messages.assignAll(mData);
        } else if (mData is Map<String, dynamic>) {
          messages.assignAll(mData['messages'] ?? mData['data'] ?? []);
        } else {
          messages.clear();
        }
      } catch (_) {
        messages.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> close(String id, {required String status, String? note}) async {
    try {
      await _service.close(id, status: status, note: note);
      showSuccess('Success'.tr);
      await load(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> cancel(String id, {String? reason, String? note}) async {
    try {
      await _service.cancel(id, reason: reason, note: note);
      showSuccess('Success'.tr);
      await load(id);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        showError('Cancel endpoint not available'.tr);
        return;
      }
      showError(e.message);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> sendMessage(String id, String message) async {
    if (message.trim().isEmpty) return;
    try {
      await _service.sendMessage(id, message: message.trim());
      await load(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> addTimeline(String id, {required String status, String? note}) async {
    try {
      await _service.addTimeline(id, status: status, note: note);
      await load(id);
      showSuccess('Success'.tr);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        showError('Timeline endpoint not available'.tr);
        return;
      }
      showError(e.message);
    } catch (e) {
      showError(e.toString());
    }
  }
}
