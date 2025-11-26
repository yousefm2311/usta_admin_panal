import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class DashboardService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> fetchStats() async {
    try {
      final res = await _dio.get('/api/admin/dashboard/stats');
      return res.data as Map<String, dynamic>;
    } on DioException catch (e) {
      // Fallback when endpoint is not available
      if (e.response?.statusCode == 404) {
        try {
          final alt = await _dio.get('/api/admin/analytics/daily');
          final data = alt.data;
          return data is Map<String, dynamic> ? data : {'monthly': data};
        } catch (_) {}
        return {};
      }
      rethrow;
    }
  }

  Future<List<dynamic>> fetchActivities() async {
    try {
      final res = await _dio.get('/api/admin/dashboard/activity');
      return res.data is List ? res.data as List<dynamic> : [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final alt = await _dio.get('/api/admin/logs/activity');
          if (alt.data is List) return alt.data as List<dynamic>;
        } catch (_) {}
        return [];
      }
      rethrow;
    }
  }

  Future<List<dynamic>> fetchTopArtisans() async {
    try {
      final res = await _dio.get('/api/admin/dashboard/top-artisans');
      return res.data is List ? res.data as List<dynamic> : [];
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          final alt = await _dio.get('/api/admin/artisans');
          if (alt.data is List) {
            return (alt.data as List<dynamic>).take(5).toList();
          } else if (alt.data is Map<String, dynamic>) {
            final list = (alt.data['artisans'] ?? alt.data['data'] ?? []) as List<dynamic>;
            return list.take(5).toList();
          }
        } catch (_) {}
        return [];
      }
      rethrow;
    }
  }
}
