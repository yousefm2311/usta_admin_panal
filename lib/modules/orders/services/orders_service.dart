import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class OrdersService {
  final Dio _dio = ApiClient().dio;

  Future<Response> list({String? status, int? page, int? perPage}) {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (page != null) params['page'] = page;
    if (perPage != null) params['perPage'] = perPage;
    return _dio.get('/api/admin/orders', queryParameters: params);
  }

  Future<Response> details(String id) => _dio.get('/api/admin/orders/$id');

  Future<Response> timeline(String id) => _dio.get('/api/admin/orders/$id/timeline');

  Future<Response> addTimeline(String id, {required String status, String? note}) async {
    final payload = {'status': status, if (note != null) 'note': note};
    try {
      return await _dio.post('/api/admin/orders/$id/timeline', data: payload);
    } catch (_) {
      return await _dio.put('/api/admin/orders/$id/timeline', data: payload);
    }
  }

  Future<Response> cancel(String id, {String? reason, String? note}) async {
    final payload = {'reason': reason, 'note': note};
    try {
      return await _dio.put('/api/admin/orders/$id/cancel', data: payload);
    } catch (_) {
      return await _dio.post('/api/admin/orders/$id/cancel', data: payload);
    }
  }

  Future<Response> close(String id, {String? note}) async {
    final payload = {'note': note};
    try {
      return await _dio.put('/api/admin/orders/$id/close', data: payload);
    } catch (_) {
      return await _dio.post('/api/admin/orders/$id/close', data: payload);
    }
  }

  Future<Response> messages(String id) => _dio.get('/api/admin/orders/$id/messages');

  Future<Response> sendMessage(String id, {required String message}) async {
    try {
      return await _dio.post('/api/admin/orders/$id/messages', data: {'message': message});
    } catch (_) {
      return await _dio.put('/api/admin/orders/$id/messages', data: {'message': message});
    }
  }
}
