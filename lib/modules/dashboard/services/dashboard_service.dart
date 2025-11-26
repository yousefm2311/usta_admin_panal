import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class DashboardService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> fetchStats() async {
    try {
      final res = await _dio.get('/api/admin/dashboard/stats');
      final data = res.data;
      return data is Map<String, dynamic> ? (data['data'] ?? data) as Map<String, dynamic> : {};
    } on DioException catch (e) {
      // Fallback when endpoint is not available
      if (e.response?.statusCode == 404) {
        try {
          final alt = await _dio.get('/api/admin/analytics/daily');
          final data = alt.data;
          if (data is Map<String, dynamic>) return data['data'] ?? data;
          return {'monthly': data};
        } catch (_) {}
        return {};
      }
      rethrow;
    }
  }

  Future<List<dynamic>> fetchActivities() async {
    try {
      final res = await _dio.get('/api/admin/dashboard/activity');
      final data = res.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>) return (data['data'] ?? data['activity'] ?? []) as List<dynamic>;
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final alt = await _dio.get('/api/admin/logs/activity');
          final data = alt.data;
          if (data is List) return data;
          if (data is Map<String, dynamic>) return (data['data'] ?? data['logs'] ?? []) as List<dynamic>;
        } catch (_) {}
        return [];
      }
      rethrow;
    }
  }

  Future<List<dynamic>> fetchTopArtisans() async {
    try {
      final res = await _dio.get('/api/admin/dashboard/top-artisans');
      final data = res.data;
      if (data is List) return data;
      if (data is Map<String, dynamic>) return (data['data'] ?? data['top'] ?? []) as List<dynamic>;
      return [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final alt = await _dio.get('/api/admin/artisans');
          if (alt.data is List) {
            return (alt.data as List<dynamic>).take(5).toList();
          } else if (alt.data is Map<String, dynamic>) {
            final list = (alt.data['artisans'] ?? alt.data['data'] ?? alt.data['top'] ?? []) as List<dynamic>;
            return list.take(5).toList();
          }
        } catch (_) {}
        return [];
      }
      rethrow;
    }
  }
}
