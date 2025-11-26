import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/roles_service.dart';

class RolesController extends GetxController {
  final RolesService _service;
  RolesController({RolesService? service}) : _service = service ?? RolesService();

  final roles = <dynamic>[].obs;
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
      final res = await _service.list();
      final data = res.data;
      if (data is List) {
        roles.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        roles.assignAll(data['roles'] ?? data['data'] ?? []);
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
      await _service.create(payload);
      await load();
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }

  Future<void> deleteRole(String id) async {
    try {
      await _service.delete(id);
      roles.removeWhere((r) => (r['_id'] ?? r['id'] ?? '') == id);
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
