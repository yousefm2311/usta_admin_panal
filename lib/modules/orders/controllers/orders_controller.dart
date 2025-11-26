import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/orders_service.dart';

class OrdersController extends GetxController {
  final OrdersService _service;
  OrdersController({OrdersService? service}) : _service = service ?? OrdersService();

  final orders = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final status = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> setStatus(String value) async {
    status.value = value;
    await load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.list(status: status.value == 'All' ? null : status.value);
      final data = res.data;
      if (data is List) {
        orders.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        orders.assignAll(data['orders'] ?? data['data'] ?? []);
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
