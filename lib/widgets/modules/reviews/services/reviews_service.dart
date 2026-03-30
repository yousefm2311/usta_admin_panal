import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';

class ReviewsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list({Map<String, dynamic>? params}) =>
      _client.safe(() => _dio.get('/api/admin/reviews', queryParameters: params));

  Future<Response> filter(Map<String, dynamic> params) =>
      _client.safe(() => _dio.get('/api/admin/reviews/filter', queryParameters: params));

  Future<Response> delete(String id) =>
      _client.safe(() => _dio.delete('/api/admin/reviews/$id'));

  Future<Response> stats() => _client.safe(() => _dio.get('/api/admin/reviews/stats'));
}
