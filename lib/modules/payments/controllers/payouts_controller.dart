import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/payouts_service.dart';

class PayoutsController extends GetxController {
  final PayoutsService _service;
  PayoutsController({PayoutsService? service}) : _service = service ?? PayoutsService();

  final wallets = <dynamic>[].obs;
  final payout = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  Future<void> loadWallets() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.walletSummary();
      final data = res.data;
      if (data is List) {
        wallets.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        wallets.assignAll(data['wallets'] ?? data['data'] ?? []);
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadPayout(String id) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.payoutDetails(id);
      final data = res.data;
      payout.value = data is Map<String, dynamic> ? (data['payout'] ?? data['data'] ?? data) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    try {
      await _service.updatePayoutStatus(id, status);
      showSuccess('Success'.tr);
      await loadPayout(id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
