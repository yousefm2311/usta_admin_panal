import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/payments_service.dart';

class PaymentDetailsController extends GetxController {
  final PaymentsService _service;
  PaymentDetailsController({PaymentsService? service}) : _service = service ?? PaymentsService();

  final payment = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String id) async {
    if (id.isEmpty) return;
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.details(id);
      final data = res.data;
      payment.value = data is Map<String, dynamic> ? (data['payment'] ?? data['data'] ?? data) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }
}
