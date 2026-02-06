import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class PaymentsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> transactions({Map<String, dynamic>? params}) => _client.safe(
    () => _dio.get('/api/admin/payments', queryParameters: params),
  );

  Future<Response> filter(Map<String, dynamic> params) => _client.safe(
    () => _dio.get('/api/admin/payments/filter', queryParameters: params),
  );

  Future<Response> details(String id) =>
      _client.safe(() => _dio.get('/api/admin/payments/$id'));

  Future<List<dynamic>> fetchRequests() async {
    final res = await _client.safe(() => _dio.get('/api/admin/requests'));
    final data = res.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return (data['requests'] ?? data['data'] ?? data['orders'] ?? [])
          as List<dynamic>;
    }
    return [];
  }

  Future<List<dynamic>> fetchArtisans() async {
    final res = await _client.safe(() => _dio.get('/api/admin/artisans'));
    final data = res.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return (data['artisans'] ?? data['data'] ?? []) as List<dynamic>;
    }
    return [];
  }
}
