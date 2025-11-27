import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/roles_service.dart';

class RolePermissionsController extends GetxController {
  final RolesService _service;
  RolePermissionsController({RolesService? service}) : _service = service ?? RolesService();

  final role = Rxn<Map<String, dynamic>>();
  final permissions = <Map<String, dynamic>>[].obs;
  final loading = false.obs;
  final error = RxnString();

  Future<void> load(String id) async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.details(id);
      final data = res.data;
      final r = data is Map<String, dynamic> ? (data['role'] ?? data['data'] ?? data) : null;
      role.value = r;
      if (r != null && r['permissions'] is List && (r['permissions'] as List).isNotEmpty) {
        permissions.assignAll(List<Map<String, dynamic>>.from(r['permissions']));
      } else {
        // fallback default modules when permissions are empty
        permissions.assignAll(_defaultPermissions);
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  List<Map<String, dynamic>> get _defaultPermissions => [
        {'module': 'dashboard', 'read': true, 'create': false, 'update': false, 'delete': false},
        {'module': 'customers', 'read': true, 'create': false, 'update': false, 'delete': false},
        {'module': 'artisans', 'read': true, 'create': false, 'update': false, 'delete': false},
        {'module': 'requests', 'read': true, 'create': false, 'update': false, 'delete': false},
        {'module': 'orders', 'read': true, 'create': false, 'update': false, 'delete': false},
        {'module': 'payments', 'read': true, 'create': false, 'update': false, 'delete': false},
        {'module': 'notifications', 'read': true, 'create': false, 'update': false, 'delete': false},
        {'module': 'categories', 'read': true, 'create': false, 'update': false, 'delete': false},
        {'module': 'roles', 'read': true, 'create': false, 'update': false, 'delete': false},
      ];

  void toggle(int index, String key) {
    if (index < 0 || index >= permissions.length) return;
    final updated = Map<String, dynamic>.from(permissions[index]);
    updated[key] = !(updated[key] == true);
    permissions[index] = updated;
  }

  Future<void> save() async {
    final id = (role.value?['_id'] ?? role.value?['id'] ?? '').toString();
    if (id.isEmpty) return;
    try {
      await _service.update(id, {'permissions': permissions});
      showSuccess('Success'.tr);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
