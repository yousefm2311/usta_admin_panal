import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class CustomersService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> fetchCustomers({String? query}) {
    return _client.safe(
      () => _dio.get('/api/admin/customers', queryParameters: query != null ? {'query': query} : null),
    );
  }

  Future<Response> search(String query) {
    return _client.safe(() => _dio.get('/api/admin/customers/search', queryParameters: {'query': query}));
  }

  Future<Response> fetchDetails(String id) {
    return _client.safe(() => _dio.get('/api/admin/customers/$id'));
  }

  Future<Response> block(String id, {bool blocked = true}) async {
    final payload = {'customerId': id, 'blocked': blocked};
    try {
      // Most backends expose the per-id endpoint; try it first to avoid noisy 404s.
      return await _client.safe(() => _dio.put('/api/admin/customers/$id/block', data: {'blocked': blocked}));
    } catch (_) {
      try {
        return await _client.safe(() => _dio.put('/api/admin/customers/block', data: payload));
      } catch (_) {
        return await _client.safe(() => _dio.post('/api/admin/customers/block', data: payload));
      }
    }
  }
}
