import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/settings_service.dart';

class SettingsController extends GetxController {
  final SettingsService _service;
  SettingsController({SettingsService? service}) : _service = service ?? SettingsService();

  final commission = 0.0.obs;
  final loading = false.obs;
  final saving = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCommission();
  }

  Future<void> loadCommission() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.getCommission();
      final data = res.data;
      final value = data is Map<String, dynamic> ? (data['commission'] ?? 0) : 0;
      commission.value = double.tryParse(value.toString()) ?? 0;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> saveCommission() async {
    saving.value = true;
    try {
      await _service.updateCommission(commission.value);
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }
}
