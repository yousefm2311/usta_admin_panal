import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ArtisansService {
  final Dio _dio = ApiClient().dio;

  Future<Response> fetchArtisans() => _dio.get('/api/admin/artisans');

  Future<Response> fetchDetails(String id) => _dio.get('/api/admin/artisans/$id');

  Future<Response> approve(String id) async {
    try {
      // Prefer per-id endpoint to avoid 404 noise
      return await _dio.put('/api/admin/artisans/$id/approve');
    } catch (_) {
      try {
        return await _dio.put('/api/admin/artisans/approve', data: {'artisanId': id});
      } catch (_) {
        return await _dio.post('/api/admin/artisans/approve', data: {'artisanId': id});
      }
    }
  }

  Future<Response> reject(String id, {String? reason}) async {
    try {
      // Primary endpoint per Postman collection uses DELETE on the id path
      return await _dio.delete('/api/admin/artisans/$id/reject', data: {'reason': reason});
    } catch (_) {
      try {
        return await _dio.put('/api/admin/artisans/$id/reject', data: {'reason': reason});
      } catch (_) {
        try {
          return await _dio.put('/api/admin/artisans/reject', data: {'artisanId': id, if (reason != null) 'reason': reason});
        } catch (_) {
          return await _dio.post('/api/admin/artisans/reject', data: {'artisanId': id, if (reason != null) 'reason': reason});
        }
      }
    }
  }
}
