import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/customers_service.dart';

class CustomerDetailsController extends GetxController {
  final CustomersService _service;
  CustomerDetailsController({CustomersService? service}) : _service = service ?? CustomersService();

  final customer = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String id) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.fetchDetails(id);
      final data = res.data;
      customer.value = data is Map<String, dynamic> ? (data['customer'] ?? data['data'] ?? data) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> blockToggle(String id, {required bool block}) async {
    try {
      await _service.block(id, blocked: block);
      showSuccess(block ? 'Blocked'.tr : 'Unblocked'.tr);
      await load(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
