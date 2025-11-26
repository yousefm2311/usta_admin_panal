import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class PayoutsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> walletSummary() => _dio.get('/api/admin/wallets');

  Future<Response> payoutDetails(String id) => _dio.get('/api/admin/payouts/$id');

  Future<Response> updatePayoutStatus(String id, String status) =>
      _dio.put('/api/admin/payouts/$id/status', data: {'status': status});
}
