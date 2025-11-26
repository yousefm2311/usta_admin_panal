import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class PaymentsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> transactions() => _dio.get('/api/admin/payments');
}
