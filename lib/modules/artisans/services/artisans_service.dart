import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ArtisansService {
  final Dio _dio = ApiClient().dio;

  Future<Response> fetchArtisans() => _dio.get('/api/admin/artisans');

  Future<Response> fetchDetails(String id) => _dio.get('/api/admin/artisans/$id');

  Future<Response> approve(String id) async {
    try {
      return await _dio.put('/api/admin/artisans/approve', data: {'artisanId': id});
    } catch (_) {
      // fallback to per-id endpoint or POST if server expects it
      try {
        return await _dio.put('/api/admin/artisans/$id/approve');
      } catch (_) {
        return await _dio.post('/api/admin/artisans/approve', data: {'artisanId': id});
      }
    }
  }

  Future<Response> reject(String id, {String? reason}) async {
    try {
      return await _dio.put('/api/admin/artisans/reject', data: {'artisanId': id, if (reason != null) 'reason': reason});
    } catch (_) {
      try {
        return await _dio.put('/api/admin/artisans/$id/reject', data: {'reason': reason});
      } catch (_) {
        return await _dio.post('/api/admin/artisans/reject', data: {'artisanId': id, if (reason != null) 'reason': reason});
      }
    }
  }
}
