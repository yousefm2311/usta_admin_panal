import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class DashboardService {
  final Dio _dio = ApiClient().dio;

  Future<Map<String, dynamic>> fetchStats() async {
    final res = await _dio.get('/api/admin/dashboard/stats');
    return res.data as Map<String, dynamic>;
  }

  Future<List<dynamic>> fetchActivities() async {
    final res = await _dio.get('/api/admin/dashboard/activity');
    return res.data is List ? res.data as List<dynamic> : [];
  }

  Future<List<dynamic>> fetchTopArtisans() async {
    final res = await _dio.get('/api/admin/dashboard/top-artisans');
    return res.data is List ? res.data as List<dynamic> : [];
  }
}
