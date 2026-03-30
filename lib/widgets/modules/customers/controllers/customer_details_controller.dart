import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/customers_service.dart';

class CustomerDetailsController extends GetxController {
  final CustomersService _service;
  CustomerDetailsController({CustomersService? service}) : _service = service ?? CustomersService();

  final customer = Rxn<Map<String, dynamic>>();
  final customerRequests = <dynamic>[].obs;
  final derivedStats = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String id) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.fetchDetails(id);
      final data = res.data;
      customer.value = data is Map<String, dynamic> ? (data['customer'] ?? data['data'] ?? data) : null;
      await _loadRequests(id);
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadRequests(String customerId) async {
    try {
      final requests = await _service.fetchAllRequests();
      final filtered = requests.where((raw) {
        final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        final id =
            (req['customerId']?['_id'] ?? req['customerId'] ?? req['customer']?['_id'] ?? req['customer'])
                ?.toString() ??
            '';
        return id == customerId;
      }).toList();
      customerRequests.assignAll(filtered);
      derivedStats.value = _computeStats(filtered);
    } catch (_) {
      customerRequests.clear();
      derivedStats.value = null;
    }
  }

  Map<String, dynamic> _computeStats(List<dynamic> requests) {
    int total = 0;
    int completed = 0;
    int cancelled = 0;
    double spend = 0;

    for (final raw in requests) {
      final req = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
      total += 1;
      final status = (req['status'] ?? '').toString().toLowerCase();
      if (status == 'completed' || status == 'closed') {
        completed += 1;
      } else if (status == 'cancelled' || status == 'canceled' || status == 'rejected') {
        cancelled += 1;
      }
      final candidate =
          req['agreedPrice'] ??
          req['price'] ??
          req['amount'] ??
          req['total'] ??
          req['pricing']?['proposedPrice'];
      final price = double.tryParse(candidate?.toString() ?? '');
      if (price != null && price > 0) {
        spend += price;
      }
    }

    return {
      'total': total,
      'completed': completed,
      'cancelled': cancelled,
      'spend': spend,
    };
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
