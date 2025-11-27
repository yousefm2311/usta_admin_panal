import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class PayoutsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> walletSummary() => _client.safe(() => _dio.get('/api/admin/wallets'));

  Future<Response> payoutDetails(String id) => _client.safe(() => _dio.get('/api/admin/payouts/$id'));

  Future<Response> updatePayoutStatus(String id, String status) =>
      _client.safe(() => _dio.put('/api/admin/payouts/$id/status', data: {'status': status}));
}
