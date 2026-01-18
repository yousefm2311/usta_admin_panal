import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/reviews_service.dart';

class ReviewsController extends GetxController {
  final ReviewsService _service;
  ReviewsController({ReviewsService? service}) : _service = service ?? ReviewsService();

  final reviews = <dynamic>[].obs;
  final stats = Rxn<Map<String, dynamic>>();
  final loading = false.obs;
  final error = RxnString();
  final filter = 'All'.obs;

  @override
  void onInit() {
    super.onInit();
    loadReviews();
    loadStats();
  }

  Future<void> loadReviews() async {
    loading.value = true;
    error.value = null;
    try {
      final res = await _service.list();
      final data = res.data;
      if (data is List) {
        reviews.assignAll(data);
      } else if (data is Map<String, dynamic>) {
        reviews.assignAll(data['reviews'] ?? data['data'] ?? []);
      } else {
        reviews.clear();
      }
    } catch (e) {
      final msg = e is ApiException ? e.message : e.toString();
      error.value = msg;
      showError(msg);
    } finally {
      loading.value = false;
    }
  }

  Future<void> loadStats() async {
    try {
      final res = await _service.stats();
      final data = res.data;
      stats.value = data is Map<String, dynamic> ? (data['stats'] ?? data) : null;
    } catch (_) {
      // stats optional
    }
  }

  List<dynamic> get filtered {
    if (filter.value == 'Positive') {
      return reviews.where((r) {
        final rating = double.tryParse((r['rating'] ?? '0').toString()) ?? 0;
        return rating >= 4;
      }).toList();
    }
    return reviews;
  }

  Future<void> deleteReview(String id) async {
    if (id.isEmpty) {
      showError('Invalid review'.tr);
      return;
    }
    try {
      await _service.delete(id);
      showSuccess('Success'.tr);
      reviews.removeWhere((r) => (r['id'] ?? r['_id'] ?? '').toString() == id);
    } catch (e) {
      showError(e is ApiException ? e.message : e.toString());
    }
  }
}
