import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ReviewsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list() => _client.safe(() => _dio.get('/api/admin/reviews'));

  Future<Response> stats() => _client.safe(() => _dio.get('/api/admin/reviews/stats'));
}
