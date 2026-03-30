import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';

class PayoutsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> walletSummary() =>
      _client.safe(() => _dio.get('/api/admin/wallets'));

  Future<Response> payoutDetails(String id) =>
      _client.safe(() => _dio.get('/api/admin/payouts/$id'));

  Future<Response> updatePayoutStatus(String id, String status) => _client.safe(
    () => _dio.put('/api/admin/payouts/$id/status', data: {'status': status}),
  );

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
