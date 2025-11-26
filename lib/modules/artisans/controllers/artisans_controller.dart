import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/artisans_service.dart';

class ArtisansController extends GetxController {
  final ArtisansService _service;
  ArtisansController({ArtisansService? service}) : _service = service ?? ArtisansService();

  final artisans = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadArtisans();
  }

  Future<void> loadArtisans() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.fetchArtisans();
      final data = res.data;
      if (data is List) {
        artisans.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        artisans.assignAll(data['artisans'] ?? data['data'] ?? []);
      } else {
        artisans.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> approve(String id) async {
    try {
      await _service.approve(id);
      showSuccess('Success'.tr);
      await loadArtisans();
    } catch (e) {
      if ((e is ApiException && e.statusCode == 404) || (e is DioException && e.response?.statusCode == 404)) {
        showError('هذا الإجراء غير مدعوم من الخادم حالياً'.tr);
        return;
      }
      showError(e is ApiException ? e.message : e.toString());
    }
  }

  Future<void> reject(String id) async {
    try {
      await _service.reject(id);
      showSuccess('Success'.tr);
      await loadArtisans();
    } catch (e) {
      if ((e is ApiException && e.statusCode == 404) || (e is DioException && e.response?.statusCode == 404)) {
        showError('هذا الإجراء غير مدعوم من الخادم حالياً'.tr);
        return;
      }
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
