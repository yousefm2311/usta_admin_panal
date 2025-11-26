import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/orders_service.dart';

class OrderDetailsController extends GetxController {
  final OrdersService _service;
  OrderDetailsController({OrdersService? service}) : _service = service ?? OrdersService();

  final order = Rxn<Map<String, dynamic>>();
  final timeline = <dynamic>[].obs;
  final messages = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String id) async {
    loading.value = true;
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
      } catch (e) {
        // Ignore missing messages endpoint (404) gracefully
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

  Future<void> addTimeline(String id, {required String status, String? note}) async {
    try {
      await _service.addTimeline(id, status: status, note: note);
      await load(id);
      showSuccess('Success'.tr);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) return;
      if (e is DioException && e.response?.statusCode == 404) return;
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> cancel(String id, {String? reason, String? note}) async {
    try {
      await _service.cancel(id, reason: reason, note: note);
      showSuccess('Success'.tr);
      await load(id);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) return;
      if (e is DioException && e.response?.statusCode == 404) return;
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> close(String id, {String? note}) async {
    try {
      await _service.close(id, note: note);
      showSuccess('Success'.tr);
      await load(id);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) return;
      if (e is DioException && e.response?.statusCode == 404) return;
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> sendMessage(String id, String message) async {
    if (message.trim().isEmpty) return;
    try {
      await _service.sendMessage(id, message: message.trim());
      await load(id);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) return;
      if (e is DioException && e.response?.statusCode == 404) return;
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
