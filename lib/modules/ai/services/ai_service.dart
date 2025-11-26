import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class AIService {
  final Dio _dio = ApiClient().dio;

  Future<Response> reviewsAnalysis() => _dio.get('/api/admin/ai/reviews-analysis');

  Future<Response> topArtisans() => _dio.get('/api/admin/ai/top-artisans');
}
