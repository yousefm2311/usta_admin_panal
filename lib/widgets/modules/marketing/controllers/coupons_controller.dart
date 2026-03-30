import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/marketing_service.dart';

class CouponsController extends GetxController {
  final MarketingService _service;
  CouponsController({MarketingService? service}) : _service = service ?? MarketingService();

  final coupons = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final saving = false.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.coupons();
      final data = res.data;
      if (data is List) {
        coupons.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        coupons.assignAll(data['data'] ?? data['coupons'] ?? []);
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> create(Map<String, dynamic> payload) async {
    saving.value = true;
    try {
      await _service.createCoupon(payload);
      await load();
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }

  Future<void> update_(String id, Map<String, dynamic> payload) async {
    saving.value = true;
    try {
      await _service.updateCoupon(id, payload);
      await load();
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }

  Future<void> delete(String id) async {
    try {
      await _service.deleteCoupon(id);
      await load();
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
