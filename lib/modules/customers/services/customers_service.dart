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
    return _dio.put('/api/admin/customers/block', data: {'customerId': id});
  }
}
