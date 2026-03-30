import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/requests_service.dart';

class RequestDetailsController extends GetxController {
  final RequestsService _service;
  RequestDetailsController({RequestsService? service}) : _service = service ?? RequestsService();

  final request = Rxn<Map<String, dynamic>>();
  final timeline = <dynamic>[].obs;
  final messages = <dynamic>[].obs;
  final loading = false.obs;
  final addingTimeline = false.obs;
  final cancelling = false.obs;
  final closing = false.obs;
  final sendingMessage = false.obs;
  final error = RxnString();

  Future<void> load(String id, {bool showLoader = true}) async {
    if (showLoader) {
      loading.value = true;
    }
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
      if (showLoader) {
        loading.value = false;
      }
    }
  }

  Future<void> close(String id, {required String status, String? note}) async {
    try {
      if (closing.value) return;
      closing.value = true;
      await _service.close(id, status: status, note: note);
      _updateLocalStatus(status);
      showSuccess('Success'.tr);
      await load(id, showLoader: false);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      closing.value = false;
    }
  }

  Future<void> cancel(String id, {String? reason, String? note}) async {
    try {
      if (cancelling.value) return;
      cancelling.value = true;
      await _service.cancel(id, reason: reason, note: note);
      _updateLocalStatus('cancelled');
      showSuccess('Success'.tr);
      await load(id, showLoader: false);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        showError('Cancel endpoint not available'.tr);
        return;
      }
      showError(e.message);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      cancelling.value = false;
    }
  }

  Future<void> sendMessage(String id, String message) async {
    if (message.trim().isEmpty) return;
    try {
      if (sendingMessage.value) return;
      sendingMessage.value = true;
      await _service.sendMessage(id, message: message.trim());
      await load(id, showLoader: false);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      sendingMessage.value = false;
    }
  }

  Future<void> addTimeline(String id, {required String status, String? note}) async {
    try {
      if (addingTimeline.value) return;
      addingTimeline.value = true;
      await _service.addTimeline(id, status: status, note: note);
      await load(id, showLoader: false);
      showSuccess('Success'.tr);
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        showError('Timeline endpoint not available'.tr);
        return;
      }
      showError(e.message);
    } catch (e) {
      showError(e.toString());
    } finally {
      addingTimeline.value = false;
    }
  }

  void _updateLocalStatus(String status) {
    final current = request.value;
    if (current == null) return;
    request.value = {...current, 'status': status};
  }
}
