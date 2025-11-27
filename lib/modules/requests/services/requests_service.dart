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

  Future<Response> cancel(String id, {String? reason, String? note}) async {
    final payload = {'status': 'canceled', if (note != null) 'note': note, if (reason != null) 'reason': reason};
    try {
      return await _dio.put('/api/admin/requests/$id/close', data: payload);
    } catch (_) {
      return await _dio.put('/api/admin/requests/$id/cancel', data: payload);
    }
  }

  Future<Response> addTimeline(String id, {required String status, String? note}) async {
    final payload = {'status': status, if (note != null) 'note': note};
    try {
      final res = await _dio.post('/api/admin/requests/$id/timeline', data: payload);
      if (_isError(res.statusCode)) throw Exception('timeline not available');
      return res;
    } catch (_) {
      try {
        final res = await _dio.put('/api/admin/requests/$id/timeline', data: payload);
        if (_isError(res.statusCode)) throw Exception('timeline put not available');
        return res;
      } catch (_) {
        // fallback to status endpoint if timeline not found
        final res = await updateStatus(id, status: status, note: note);
        if (_isError(res.statusCode)) throw Exception('timeline not available');
        return res;
      }
    }
  }

  bool _isError(int? status) => status != null && status >= 400;

  Future<Response> messages(String id) => _dio.get('/api/admin/requests/$id/messages');

  Future<Response> sendMessage(String id, {required String message}) =>
      _dio.post('/api/admin/requests/$id/messages', data: {'message': message});

  Future<Response> updateStatus(String id, {required String status, String? note}) =>
      _dio.put('/api/admin/requests/$id/status', data: {'status': status, if (note != null) 'note': note});
}
