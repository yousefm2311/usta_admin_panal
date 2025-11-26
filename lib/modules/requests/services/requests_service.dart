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

  Future<Response> close(String id, {required String status, String? note}) =>
      _dio.put('/api/admin/requests/$id/close', data: {'status': status, if (note != null) 'note': note});

  Future<Response> cancel(String id, {String? reason, String? note}) =>
      _dio.put('/api/admin/requests/$id/cancel', data: {'reason': reason, 'note': note});

  Future<Response> addTimeline(String id, {required String status, String? note}) =>
      _dio.post('/api/admin/requests/$id/timeline', data: {'status': status, if (note != null) 'note': note});

  Future<Response> messages(String id) => _dio.get('/api/admin/requests/$id/messages');

  Future<Response> sendMessage(String id, {required String message}) =>
      _dio.post('/api/admin/requests/$id/messages', data: {'message': message});
}
