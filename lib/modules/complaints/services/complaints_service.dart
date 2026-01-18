import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ComplaintsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list({String? status, int? page, int? perPage}) {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (page != null) params['page'] = page;
    if (perPage != null) params['perPage'] = perPage;
    return _client.safe(() => _dio.get('/api/admin/complaints', queryParameters: params));
  }

  Future<Response> details(String id) => _client.safe(() => _dio.get('/api/admin/complaints/$id'));

  Future<Response> updateStatus(String id, String status) =>
      _client.safe(() => _dio.put('/api/admin/complaints/$id/status', data: {'status': status}));

  Future<Response> assign(String id, String agentId) =>
      _client.safe(() => _dio.put('/api/admin/complaints/$id/assign', data: {'agentId': agentId}));

  Future<Response> addMessage(String id, Map<String, dynamic> payload) =>
      _client.safe(() => _dio.post('/api/admin/complaints/$id/messages', data: payload));

  Future<Response> addNote(String id, String note) =>
      _client.safe(() => _dio.post('/api/admin/complaints/$id/note', data: {'note': note}));
}
