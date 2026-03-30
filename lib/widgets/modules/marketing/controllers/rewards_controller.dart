import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/marketing_service.dart';

class RewardsController extends GetxController {
  final MarketingService _service;
  RewardsController({MarketingService? service}) : _service = service ?? MarketingService();

  final data = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.rewards();
      final payload = res.data;
      data.value = payload is Map<String, dynamic> ? (payload['data'] ?? payload) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }
}
