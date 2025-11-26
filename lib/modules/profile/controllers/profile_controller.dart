import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/profile_service.dart';

class ProfileController extends GetxController {
  final ProfileService _service;
  ProfileController({ProfileService? service}) : _service = service ?? ProfileService();

  final profile = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  Future<void> loadProfile() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.me();
      final data = res.data;
      profile.value = data is Map<String, dynamic> ? (data['admin'] ?? data['data'] ?? data) : null;
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }
}
