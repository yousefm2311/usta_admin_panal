import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class AnalyticsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> daily() => _client.safe(() => _dio.get('/api/admin/analytics/daily'));

  Future<Response> revenue() => _client.safe(() => _dio.get('/api/admin/analytics/revenue'));

  Future<Response> activeUsers() => _client.safe(() => _dio.get('/api/admin/analytics/active-users'));
}
