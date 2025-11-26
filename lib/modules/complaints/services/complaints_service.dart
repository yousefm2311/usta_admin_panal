import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ComplaintsService {
  final Dio _dio = ApiClient().dio;

  Future<Response> list({String? status, int? page, int? perPage}) {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (page != null) params['page'] = page;
    if (perPage != null) params['perPage'] = perPage;
    return _dio.get('/api/admin/complaints', queryParameters: params);
  }

  Future<Response> details(String id) => _dio.get('/api/admin/complaints/$id');

  Future<Response> updateStatus(String id, String status) =>
      _dio.put('/api/admin/complaints/$id/status', data: {'status': status});

  Future<Response> assign(String id, String agentId) =>
      _dio.put('/api/admin/complaints/$id/assign', data: {'agentId': agentId});

  Future<Response> addMessage(String id, Map<String, dynamic> payload) =>
      _dio.post('/api/admin/complaints/$id/messages', data: payload);
}
