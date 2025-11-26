import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ReviewsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> list() => _dio.get('/api/admin/reviews');

  Future<Response> stats() => _dio.get('/api/admin/reviews/stats');
}
