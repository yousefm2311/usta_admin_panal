import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/customers_service.dart';

class CustomersController extends GetxController {
  final CustomersService _service;
  CustomersController({CustomersService? service}) : _service = service ?? CustomersService();

  final customers = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final query = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers({String? search}) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.fetchCustomers(query: search);
      final data = res.data;
      if (data is List) {
        customers.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        customers.assignAll(data['customers'] ?? data['data'] ?? []);
      } else {
        customers.clear();
      }
    } catch (e) {
      if (e is ApiException) {
        error.value = e.message;
        showError(e.message);
      } else {
        error.value = e.toString();
        showError(e.toString());
      }
    } finally {
      loading.value = false;
    }
  }

  Future<void> blockCustomer(String id) async {
    try {
      await _service.block(id);
      showSuccess('Success'.tr);
      await loadCustomers(search: query.value.isNotEmpty ? query.value : null);
    } catch (e) {
      if (e is ApiException) {
        showError(e.message);
      } else {
        showError(e.toString());
      }
    }
  }

  void setQuery(String q) {
    query.value = q;
  }
}
