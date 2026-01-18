import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class WithdrawalsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list() => _client.safe(() => _dio.get('/api/admin/withdrawals'));

  Future<Response> approve(String id) =>
      _client.safe(() => _dio.put('/api/admin/withdrawals/$id/approve'));

  Future<Response> reject(String id) =>
      _client.safe(() => _dio.put('/api/admin/withdrawals/$id/reject'));
}
