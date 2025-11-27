import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class PaymentsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> transactions() => _client.safe(() => _dio.get('/api/admin/payments'));
}
