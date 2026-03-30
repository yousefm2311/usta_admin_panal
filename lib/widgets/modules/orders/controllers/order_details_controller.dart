import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/orders_service.dart';

class OrderDetailsController extends GetxController {
  final OrdersService _service;
  OrderDetailsController({OrdersService? service}) : _service = service ?? OrdersService();

  final order = Rxn<Map<String, dynamic>>();
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
      final res = await _service.details(id);
      final data = res.data;
      order.value = data is Map<String, dynamic> ? (data['order'] ?? data['data'] ?? data) : null;
      final timelineRes = await _service.timeline(id);
      final tData = timelineRes.data;
      if (tData is List) {
        timeline.assignAll(tData);
      } else if (tData is Map<String, dynamic>) {
        timeline.assignAll(tData['timeline'] ?? tData['data'] ?? []);
      }
      try {
        final msgRes = await _service.messages(id);
        final mData = msgRes.data;
        if (mData is List) {
          messages.assignAll(mData);
        } else if (mData is Map<String, dynamic>) {
          messages.assignAll(mData['messages'] ?? mData['data'] ?? []);
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

  Future<void> addTimeline(String id, {required String status, String? note}) async {
    try {
      if (addingTimeline.value) return;
      addingTimeline.value = true;
      await _service.addTimeline(id, status: status, note: note);
      await load(id, showLoader: false);
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      addingTimeline.value = false;
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
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      cancelling.value = false;
    }
  }

  Future<void> close(String id, {String? note}) async {
    try {
      if (closing.value) return;
      closing.value = true;
      await _service.close(id, note: note);
      _updateLocalStatus('closed');
      showSuccess('Success'.tr);
      await load(id, showLoader: false);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      closing.value = false;
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

  void _updateLocalStatus(String status) {
    final current = order.value;
    if (current == null) return;
    order.value = {...current, 'status': status};
  }
}
