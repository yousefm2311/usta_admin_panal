import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class RequestsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> fetchRequests({String? status}) {
    if (status != null && status.isNotEmpty) {
      return _dio.get('/api/admin/requests/filter', queryParameters: {'status': status});
    }
    return _dio.get('/api/admin/requests');
  }

  Future<Response> fetchDetails(String id) => _dio.get('/api/admin/requests/$id');

  Future<Response> timeline(String id) => _dio.get('/api/admin/requests/$id/timeline');

  Future<Response> close(String id) => _dio.put('/api/admin/requests/close', data: {'requestId': id});
}
