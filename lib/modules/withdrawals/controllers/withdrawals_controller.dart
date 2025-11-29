import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/withdrawals_service.dart';

class WithdrawalsController extends GetxController {
  final WithdrawalsService _service;
  WithdrawalsController({WithdrawalsService? service}) : _service = service ?? WithdrawalsService();

  final withdrawals = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadWithdrawals();
  }

  Future<void> loadWithdrawals() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.list();
      final data = res.data;
      if (data is List) {
        withdrawals.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        // API returns {data: {withdrawals: [...]}} structure
        final innerData = data['data'];
        if (innerData is Map<String, dynamic>) {
          withdrawals.assignAll(innerData['withdrawals'] ?? []);
        } else {
          withdrawals.assignAll(data['withdrawals'] ?? []);
        }
      } else {
        withdrawals.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> approve(String id) async {
    try {
      await _service.approve(id);
      showSuccess('Success'.tr);
      await loadWithdrawals();
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> reject(String id) async {
    try {
      await _service.reject(id);
      showSuccess('Rejected'.tr);
      await loadWithdrawals();
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
