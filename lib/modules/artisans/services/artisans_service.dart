import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ArtisansService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> fetchArtisans() => _client.safe(() => _dio.get('/api/admin/artisans'));

  Future<Response> filterArtisans(Map<String, dynamic> params) =>
      _client.safe(() => _dio.get('/api/admin/artisans/filter', queryParameters: params));

  Future<Response> fetchDetails(String id) => _client.safe(() => _dio.get('/api/admin/artisans/$id'));

  Future<List<dynamic>> fetchReviews() async {
    final res = await _client.safe(() => _dio.get('/api/admin/reviews'));
    final data = res.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return (data['reviews'] ?? data['data'] ?? []) as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchRequests() async {
    final res = await _client.safe(() => _dio.get('/api/admin/requests'));
    final data = res.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return (data['requests'] ?? data['data'] ?? data['orders'] ?? []) as List<dynamic>;
    }
    return [];
  }

  Future<Response> approve(String id) async {
    try {
      // Prefer per-id endpoint to avoid 404 noise
      return await _client.safe(() => _dio.put('/api/admin/artisans/$id/approve'));
    } catch (_) {
      try {
        return await _client.safe(() => _dio.put('/api/admin/artisans/approve', data: {'artisanId': id}));
      } catch (_) {
        return await _client.safe(() => _dio.post('/api/admin/artisans/approve', data: {'artisanId': id}));
      }
    }
  }

  Future<Response> reject(String id, {String? reason}) async {
    try {
      // Primary endpoint per Postman collection uses DELETE on the id path
      return await _client.safe(() => _dio.delete('/api/admin/artisans/$id/reject', data: {'reason': reason}));
    } catch (_) {
      try {
        return await _client.safe(() => _dio.put('/api/admin/artisans/$id/reject', data: {'reason': reason}));
      } catch (_) {
        try {
          return await _client.safe(() =>
              _dio.put('/api/admin/artisans/reject', data: {'artisanId': id, if (reason != null) 'reason': reason}));
        } catch (_) {
          return await _client.safe(() => _dio
              .post('/api/admin/artisans/reject', data: {'artisanId': id, if (reason != null) 'reason': reason}));
        }
      }
    }
  }

  Future<Response> updateStatus(String id, {required bool suspended}) =>
      _client.safe(() => _dio.put('/api/admin/artisans/$id/status', data: {'suspended': suspended}));
}
