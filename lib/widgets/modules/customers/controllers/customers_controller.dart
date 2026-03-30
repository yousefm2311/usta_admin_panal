import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/customers_service.dart';

class CustomersController extends GetxController {
  final CustomersService _service;
  CustomersController({CustomersService? service}) : _service = service ?? CustomersService();

  final customers = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final query = ''.obs;
  final requestCounts = <String, int>{}.obs;
  final requestCountsLoading = <String, bool>{}.obs;
  final requestsCountLoadingAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadCustomers();
  }

  Future<void> loadCustomers({String? search}) async {
    loading.value = true;
    error.value = null;
    try {
      requestCounts.clear();
      requestCountsLoading.clear();
      requestsCountLoadingAll.value = false;
      final res = await _service.fetchCustomers(query: search);
      final data = res.data;
      if (data is List) {
        customers.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        customers.assignAll(data['customers'] ?? data['data'] ?? []);
      } else {
        customers.clear();
      }
      _loadRequestCountsForCustomers(customers);
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

  void _loadRequestCountsForCustomers(List<dynamic> list) {
    if (list.isEmpty) return;
    _loadAllRequestCounts();
  }

  Future<void> _loadAllRequestCounts() async {
    requestsCountLoadingAll.value = true;
    try {
      final requests = await _service.fetchAllRequests();
      final counts = <String, int>{};
      for (final raw in requests) {
        final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        final customerId =
            (req['customerId']?['_id'] ?? req['customerId'] ?? req['customer']?['_id'] ?? req['customer'])?.toString() ??
            '';
        if (customerId.isEmpty) continue;
        counts[customerId] = (counts[customerId] ?? 0) + 1;
      }
      requestCounts.assignAll(counts);
    } catch (_) {
      // Keep fallback counts if endpoint is unavailable.
    } finally {
      requestsCountLoadingAll.value = false;
    }
  }

  Future<void> blockCustomer(String id, {required bool block}) async {
    try {
      await _service.block(id, blocked: block);
      showSuccess(block ? 'Blocked'.tr : 'Unblocked'.tr);
      await loadCustomers(search: query.value.isNotEmpty ? query.value : null);
    } catch (e) {
      if (e is ApiException && e.statusCode == 404) {
        showError('إيقاف العميل غير مدعوم حالياً من الخادم'.tr);
        return;
      }
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> deleteCustomer(String id) async {
    if (id.isEmpty) {
      showError('Invalid customer'.tr);
      return;
    }
    try {
      await _service.delete(id);
      showSuccess('Success'.tr);
      customers.removeWhere((c) => (c['id'] ?? c['_id'] ?? '').toString() == id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  void setQuery(String q) {
    query.value = q;
  }
}
