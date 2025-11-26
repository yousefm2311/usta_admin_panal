import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class AnalyticsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> daily() => _dio.get('/api/admin/analytics/daily');
}
