import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class CustomersService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> fetchCustomers({String? query}) {
    if (query != null && query.isNotEmpty) {
      return search(query);
    }
    return _client.safe(() => _dio.get('/api/admin/customers'));
  }

  Future<Response> search(String query) {
    return _client.safe(() => _dio.get('/api/admin/customers/search', queryParameters: {'query': query}));
  }

  Future<Response> fetchDetails(String id) {
    return _client.safe(() => _dio.get('/api/admin/customers/$id'));
  }

  Future<List<dynamic>> fetchAllRequests() async {
    final res = await _client.safe(() => _dio.get('/api/admin/requests'));
    final data = res.data;
    if (data is List) return data;
    if (data is Map<String, dynamic>) {
      return (data['requests'] ?? data['data'] ?? data['orders'] ?? []) as List<dynamic>;
    }
    return [];
  }

  Future<Response> delete(String id) =>
      _client.safe(() => _dio.delete('/api/admin/customers/$id'));

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

  int _extractRequestsCount(dynamic data) {
    if (data is List) return data.length;
    if (data is Map<String, dynamic>) {
      final direct =
          data['count'] ??
          data['total'] ??
          data['totalRequests'] ??
          data['requestsCount'] ??
          data['totalCount'] ??
          data['total_count'];
      final directParsed = int.tryParse(direct?.toString() ?? '');
      if (directParsed != null) return directParsed;

      final inner = data['data'] ?? data['requests'] ?? data['history'] ?? data['orders'];
      if (inner is List) return inner.length;
      if (inner is Map<String, dynamic>) {
        final innerDirect =
            inner['count'] ??
            inner['total'] ??
            inner['totalRequests'] ??
            inner['requestsCount'] ??
            inner['totalCount'] ??
            inner['total_count'];
        final innerParsed = int.tryParse(innerDirect?.toString() ?? '');
        if (innerParsed != null) return innerParsed;
        final innerList =
            inner['data'] ?? inner['requests'] ?? inner['history'] ?? inner['orders'];
        if (innerList is List) return innerList.length;
      }
    }
    return 0;
  }
}
