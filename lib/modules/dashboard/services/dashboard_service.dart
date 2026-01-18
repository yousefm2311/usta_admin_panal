import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class DashboardService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Map<String, dynamic>> fetchStats() async {
    // Primary endpoint available on current backend
    try {
      final altDash = await _client.safe(() => _dio.get('/api/admin/dashboard'));
      final d = altDash.data;
      if (d is Map<String, dynamic>) return d['data'] ?? d;
    } catch (_) {}
    // Fallback to older stats endpoint if present
    try {
      final res = await _client.safe(() => _dio.get('/api/admin/dashboard/stats'));
      final data = res.data;
      return data is Map<String, dynamic> ? (data['data'] ?? data) as Map<String, dynamic> : {};
    } catch (_) {}
    // Final fallback to analytics daily
    try {
      final alt = await _client.safe(() => _dio.get('/api/admin/analytics/daily'));
      final data = alt.data;
      if (data is Map<String, dynamic>) return data['data'] ?? data;
      return {'daily': data};
    } catch (_) {}
    return {};
  }

  Future<List<dynamic>> fetchActivities() async {
    // Prefer dashboard activity endpoint when available.
    try {
      final res = await _client.safe(() => _dio.get('/api/admin/dashboard/activity'));
      final data = res.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>) return (data['data'] ?? data['logs'] ?? []) as List<dynamic>;
    } catch (_) {}
    // Fallback to activity logs endpoint.
    try {
      final alt = await _client.safe(() => _dio.get('/api/admin/logs/activity'));
      final data = alt.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>) return (data['data'] ?? data['logs'] ?? []) as List<dynamic>;
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> fetchTopArtisans() async {
    // Prefer AI top-artisans endpoint which exists on backend
    try {
      final res = await _client.safe(() => _dio.get('/api/admin/ai/top-artisans'));
      final data = res.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>) return (data['data'] ?? data['top'] ?? []) as List<dynamic>;
    } catch (_) {}
    // Fallback to dashboard top-artisans
    try {
      final res = await _client.safe(() => _dio.get('/api/admin/dashboard/top-artisans'));
      final data = res.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>) return (data['data'] ?? data['top'] ?? []) as List<dynamic>;
    } catch (_) {}
    // Fallback to list artisans and take top 5
    try {
      final alt = await _client.safe(() => _dio.get('/api/admin/artisans'));
      if (alt.data is List) {
        return (alt.data as List<dynamic>).take(5).toList();
      } else if (alt.data is Map<String, dynamic>) {
        final list = (alt.data['artisans'] ?? alt.data['data'] ?? alt.data['top'] ?? []) as List<dynamic>;
        return list.take(5).toList();
      }
    } catch (_) {}
    return [];
  }

  Future<List<dynamic>> fetchLatestRequests() async {
    try {
      final res = await _client.safe(() => _dio.get('/api/admin/requests', queryParameters: {'page': 1, 'perPage': 5}));
      final data = res.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>) return (data['requests'] ?? data['data'] ?? []) as List<dynamic>;
      return [];
    } catch (_) {
      return [];
    }
  }
}
