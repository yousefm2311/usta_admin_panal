import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class MarketingService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> coupons({int? page, int? perPage}) {
    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (perPage != null) params['perPage'] = perPage;
    return _client.safe(() => _dio.get('/api/admin/marketing/coupons', queryParameters: params));
  }

  Future<Response> createCoupon(Map<String, dynamic> payload) =>
      _client.safe(() => _dio.post('/api/admin/marketing/coupons', data: payload));

  Future<Response> updateCoupon(String id, Map<String, dynamic> payload) =>
      _client.safe(() => _dio.put('/api/admin/marketing/coupons/$id', data: payload));

  Future<Response> deleteCoupon(String id) => _client.safe(() => _dio.delete('/api/admin/marketing/coupons/$id'));

  Future<Response> referral() => _client.safe(() => _dio.get('/api/admin/marketing/referral'));

  Future<Response> rewards() => _client.safe(() => _dio.get('/api/admin/marketing/rewards'));
}
