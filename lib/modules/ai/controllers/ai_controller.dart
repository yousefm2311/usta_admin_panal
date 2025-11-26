import 'package:get/get.dart';

import '../../../core/services/api_exceptions.dart';
import '../../../core/utils/notify.dart';
import '../services/ai_service.dart';

class AIController extends GetxController {
  final AIService _service;
  AIController({AIService? service}) : _service = service ?? AIService();

  final sentiment = <String, double>{}.obs;
  final topArtisans = <dynamic>[].obs;
  final wordCloud = <String>[].obs;
  final loadingSentiment = false.obs;
  final loadingTop = false.obs;
  final loadingWordCloud = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    loadSentiment();
    loadTopArtisans();
    loadWordCloud();
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

  Future<void> loadWordCloud() async {
    loadingWordCloud.value = true;
    try {
      final res = await _service.wordCloud();
      final data = res.data;
      if (data is List) {
        wordCloud.assignAll(data.map((e) => e.toString()));
      } else if (data is Map<String, dynamic>) {
        final list = data['data'] ?? data['words'];
        if (list is List) {
          wordCloud.assignAll(list.map((e) => e.toString()));
        }
      }
    } catch (_) {
      // ignore: no error surfacing for optional word cloud
    } finally {
      loadingWordCloud.value = false;
    }
  }
}
