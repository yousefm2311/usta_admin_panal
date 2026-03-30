import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';

class AnalyticsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> daily() => _client.safe(() => _dio.get('/api/admin/analytics/daily'));

  Future<Response> revenue() => _client.safe(() => _dio.get('/api/admin/analytics/revenue'));

  Future<Response> activeUsers() => _client.safe(() => _dio.get('/api/admin/analytics/active-users'));

  Future<List<dynamic>> fetchRequests() async {
    final res = await _client.safe(() => _dio.get('/api/admin/requests'));
    final data = res.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return (data['requests'] ?? data['data'] ?? data['orders'] ?? []) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchReviews() async {
    final res = await _client.safe(() => _dio.get('/api/admin/reviews'));
    final data = res.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return (data['reviews'] ?? data['data'] ?? []) as List<dynamic>;
    }
    return [];
  }
}
