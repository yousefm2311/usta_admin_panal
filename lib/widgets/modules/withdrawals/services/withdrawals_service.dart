import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';

class WithdrawalsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list() =>
      _client.safe(() => _dio.get('/api/admin/withdrawals'));

  Future<Response> approve(String id) =>
      _client.safe(() => _dio.put('/api/admin/withdrawals/$id/approve'));

  Future<Response> reject(String id) =>
      _client.safe(() => _dio.put('/api/admin/withdrawals/$id/reject'));

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
