import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/categories_service.dart';

class CategoriesController extends GetxController {
  final CategoriesService _service;
  CategoriesController({CategoriesService? service}) : _service = service ?? CategoriesService();

  final categories = <dynamic>[].obs;
  final loading = false.obs;
  final saving = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadCategories();
  }

  Future<void> loadCategories() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.list();
      final data = res.data;
      if (data is List) {
        categories.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        categories.assignAll(data['categories'] ?? data['data'] ?? []);
      } else {
        categories.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> addCategory({required String name, required String icon}) async {
    saving.value = true;
    try {
      await _service.create(name: name, icon: icon);
      showSuccess('Success'.tr);
      await loadCategories();
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }

  Future<void> removeCategory(String id) async {
    if (id.isEmpty) {
      showError('Invalid category'.tr);
      return;
    }
    try {
      await _service.delete(id);
      showSuccess('Success'.tr);
      categories.removeWhere((c) => (c['id'] ?? c['_id'] ?? '').toString() == id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> updateCategory(String id, {required String name}) async {
    if (id.isEmpty || name.trim().isEmpty) {
      showError('Invalid category'.tr);
      return;
    }
    saving.value = true;
    try {
      await _service.update(id, name: name.trim());
      showSuccess('Success'.tr);
      final index = categories.indexWhere((c) => (c['id'] ?? c['_id'] ?? '').toString() == id);
      if (index != -1) {
        final current = categories[index];
        categories[index] = {...current, 'name': name.trim()};
        categories.refresh();
      }
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    } finally {
      saving.value = false;
    }
  }
}
