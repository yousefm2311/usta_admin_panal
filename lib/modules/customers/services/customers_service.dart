import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class CustomersService {
  final Dio _dio = ApiClient().dio;

  Future<Response> fetchCustomers({String? query}) {
    return _dio.get('/api/admin/customers', queryParameters: query != null ? {'query': query} : null);
  }

  Future<Response> search(String query) {
    return _dio.get('/api/admin/customers/search', queryParameters: {'query': query});
  }

  Future<Response> fetchDetails(String id) {
    return _dio.get('/api/admin/customers/$id');
  }

  Future<Response> block(String id) {
    final payload = {'customerId': id, 'blocked': true};
    return _dio.put('/api/admin/customers/block', data: payload).catchError((_) async {
      try {
        return await _dio.put('/api/admin/customers/$id/block', data: {'blocked': true});
      } catch (_) {
        return await _dio.post('/api/admin/customers/block', data: payload);
      }
    });
  }
}
