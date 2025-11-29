import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class AIService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> reviewsAnalysis() =>
      _client.safe(() => _dio.get('/api/admin/ai/reviews-analysis'));

  Future<Response> topArtisans() =>
      _client.safe(() => _dio.get('/api/admin/ai/top-artisans'));

  Future<Response> wordCloud() =>
      _client.safe(() => _dio.get('/api/admin/ai/word-cloud'));

  Future<Response> fraudDetection() =>
      _client.safe(() => _dio.get('/api/admin/ai/fraud-detection'));
}
