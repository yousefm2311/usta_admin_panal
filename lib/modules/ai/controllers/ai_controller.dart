import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/ai_service.dart';

class AIController extends GetxController {
  final AIService _service;
  AIController({AIService? service}) : _service = service ?? AIService();

  final sentiment = <String, double>{}.obs;
  final topArtisans = <dynamic>[].obs;
  final loadingSentiment = false.obs;
  final loadingTop = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadSentiment();
    loadTopArtisans();
  }

  Future<void> loadSentiment() async {
    loadingSentiment.value = true;
    try {
      final res = await _service.reviewsAnalysis();
      final data = res.data;
      if (data is Map<String, dynamic>) {
        sentiment.assignAll(data.map((key, value) => MapEntry(key, double.tryParse(value.toString()) ?? 0)));
      }
    } catch (e) {
      error.value = e is ApiException ? e.message : e.toString();
      showError(error.value!);
    } finally {
      loadingSentiment.value = false;
    }
  }

  Future<void> loadTopArtisans() async {
    loadingTop.value = true;
    try {
      final res = await _service.topArtisans();
      final data = res.data;
      topArtisans.assignAll(data is List ? data : data['data'] ?? []);
    } catch (e) {
      error.value = e is ApiException ? e.message : e.toString();
      showError(error.value!);
    } finally {
      loadingTop.value = false;
    }
  }
}
