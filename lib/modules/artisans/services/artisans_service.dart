import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ArtisansService {
  final Dio _dio = ApiClient().dio;

  Future<Response> fetchArtisans() => _dio.get('/api/admin/artisans');

  Future<Response> fetchDetails(String id) => _dio.get('/api/admin/artisans/$id');

  Future<Response> approve(String id) => _dio.put('/api/admin/artisans/approve', data: {'artisanId': id});

  Future<Response> reject(String id) => _dio.put('/api/admin/artisans/reject', data: {'artisanId': id});
}
