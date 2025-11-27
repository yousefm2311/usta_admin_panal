import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/requests_service.dart';

class RequestsController extends GetxController {
  final RequestsService _service;
  RequestsController({RequestsService? service}) : _service = service ?? RequestsService();

  final requests = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final filter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadRequests();
  }

  Future<void> changeFilter(String value) async {
    filter.value = value;
    await loadRequests(status: value);
  }

  Future<void> loadRequests({String? status}) async {
    loading.value = true;
    error.value = null;
    try {
      final mapped = _mapStatus(status);
      final res = await _service.fetchRequests(status: mapped);
      final data = res.data;
      if (data is List) {
        requests.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        requests.assignAll(data['requests'] ?? data['data'] ?? []);
      } else {
        requests.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  String? _mapStatus(String? status) {
    if (status == null || status == 'All') return null;
    switch (status.toLowerCase()) {
      case 'new':
        return 'new';
      case 'pending':
        return 'pending';
      case 'accepted':
        return 'accepted';
      case 'assigned':
        return 'assigned';
      case 'in progress':
      case 'in-progress':
        return 'in-progress';
      case 'completed':
        return 'completed';
      case 'cancelled':
      case 'canceled':
        return 'cancelled';
      default:
        return status.toLowerCase();
    }
  }
}
