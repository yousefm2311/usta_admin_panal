import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class PaymentsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> transactions({Map<String, dynamic>? params}) =>
      _client.safe(() => _dio.get('/api/admin/payments', queryParameters: params));

  Future<Response> filter(Map<String, dynamic> params) =>
      _client.safe(() => _dio.get('/api/admin/payments/filter', queryParameters: params));

  Future<Response> details(String id) =>
      _client.safe(() => _dio.get('/api/admin/payments/$id'));
}
