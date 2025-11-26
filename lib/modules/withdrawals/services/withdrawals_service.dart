import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class WithdrawalsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> list() => _dio.get('/api/admin/withdrawals');

  Future<Response> approve(String id) => _dio.put('/api/admin/withdrawals/approve', data: {'withdrawalId': id});
}
