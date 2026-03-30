import 'package:get/get.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/settings_service.dart';

class SettingsSecurityController extends GetxController {
  final SettingsService _service;
  SettingsSecurityController({SettingsService? service}) : _service = service ?? SettingsService();

  final loading = false.obs;
  final error = RxnString();
  final data = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.getSecurity();
      final payload = res.data;
      if (payload is Map<String, dynamic>) {
        data.value = payload['data'] is Map<String, dynamic> ? payload['data'] as Map<String, dynamic> : payload;
      } else {
        data.value = null;
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }
}
