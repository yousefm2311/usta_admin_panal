import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class AnalyticsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> daily() => _client.safe(() => _dio.get('/api/admin/analytics/daily'));
}
