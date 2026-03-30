import 'package:get/get.dart';
import 'package:dio/dio.dart';

import '../../../../core/services/api_exceptions.dart';
import '../../../../core/utils/notify.dart';
import '../services/artisans_service.dart';

class ArtisansController extends GetxController {
  final ArtisansService _service;
  ArtisansController({ArtisansService? service}) : _service = service ?? ArtisansService();

  final artisans = <dynamic>[].obs;
  final loading = false.obs;
  final error = RxnString();
  final artisanRatings = <String, double>{}.obs;
  final ratingsLoadingAll = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadArtisans();
  }

  Future<void> loadArtisans() async {
    loading.value = true;
    error.value = null;
    try {
      artisanRatings.clear();
      ratingsLoadingAll.value = false;
      final res = await _service.fetchArtisans();
      final data = res.data;
      if (data is List) {
        artisans.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        artisans.assignAll(data['artisans'] ?? data['data'] ?? []);
      } else {
        artisans.clear();
      }
      _loadRatingsForArtisans();
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> _loadRatingsForArtisans() async {
    if (artisans.isEmpty) return;
    ratingsLoadingAll.value = true;
    try {
      final reviews = await _service.fetchReviews();
      final sum = <String, double>{};
      final counts = <String, int>{};
      for (final raw in reviews) {
        final review = raw is Map<String, dynamic> ? raw : <String, dynamic>{};
        final artisanId =
            (review['artisanId']?['_id'] ?? review['artisanId'] ?? review['artisan']?['_id'] ?? review['artisan'])
                ?.toString() ??
            '';
        if (artisanId.isEmpty) continue;
        final rating = double.tryParse((review['rating'] ?? 0).toString()) ?? 0;
        sum[artisanId] = (sum[artisanId] ?? 0) + rating;
        counts[artisanId] = (counts[artisanId] ?? 0) + 1;
      }
      final averages = <String, double>{};
      for (final entry in sum.entries) {
        final count = counts[entry.key] ?? 0;
        if (count > 0) {
          averages[entry.key] = entry.value / count;
        }
      }
      artisanRatings.assignAll(averages);
    } catch (_) {
      // Keep fallback ratings if endpoint is unavailable.
    } finally {
      ratingsLoadingAll.value = false;
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

  Future<void> setSuspended(String id, {required bool suspended}) async {
    if (id.isEmpty) {
      showError('Invalid artisan'.tr);
      return;
    }
    try {
      await _service.updateStatus(id, suspended: suspended);
      showSuccess('Success'.tr);
      await loadArtisans();
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
