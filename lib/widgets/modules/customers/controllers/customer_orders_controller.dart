import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/customers_service.dart';

class CustomerOrdersController extends GetxController {
  final CustomersService _service;
  CustomerOrdersController({CustomersService? service})
      : _service = service ?? CustomersService();

  final orders = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String customerId) async {
    if (customerId.isEmpty) return;
    loading.value = true;
    error.value = null;
    try {
      final requests = await _service.fetchAllRequests();
      final filtered = requests.where((raw) {
        final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        final id =
            (req['customerId']?['_id'] ??
                    req['customerId'] ??
                    req['customer']?['_id'] ??
                    req['customer'])
                ?.toString() ??
            '';
        return id == customerId;
      }).toList();
      orders.assignAll(filtered);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }
}
