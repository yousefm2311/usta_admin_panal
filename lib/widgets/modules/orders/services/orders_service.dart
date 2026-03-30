import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_exceptions.dart';

class OrdersService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> list({String? status, int? page, int? perPage}) {
    final params = <String, dynamic>{};
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (page != null) params['page'] = page;
    if (perPage != null) params['perPage'] = perPage;
    return _client.safe(() => _dio.get('/api/admin/orders', queryParameters: params));
  }

  Future<Response> details(String id) => _client.safe(() => _dio.get('/api/admin/orders/$id'));

  Future<Response> timeline(String id) async {
    try {
      return await _client.safe(() => _dio.get('/api/admin/orders/$id/timeline'));
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        // Fallback to requests timeline if orders timeline is not available on backend
        return await _client.safe(() => _dio.get('/api/admin/requests/$id/timeline'));
      }
      throw mapDioException(e);
    }
  }

  Future<Response> addTimeline(String id, {required String status, String? note}) async {
    final payload = {'status': status, if (note != null) 'note': note};
    try {
      final res = await _client.safe(() => _dio.post('/api/admin/orders/$id/timeline', data: payload));
      if (_isError(res.statusCode)) throw Exception('timeline not available');
      return res;
    } catch (_) {
      try {
        // Fallback to requests timeline endpoint
        final res = await _client.safe(() => _dio.post('/api/admin/requests/$id/timeline', data: payload));
        if (_isError(res.statusCode)) throw Exception('requests timeline not available');
        return res;
      } catch (err) {
        try {
          final res = await updateStatus(id, status: status, note: note);
          if (_isError(res.statusCode)) throw Exception('status update failed');
          return res;
        } catch (err2) {
          if (err2 is DioException) throw mapDioException(err2);
          if (err is DioException) throw mapDioException(err);
          rethrow;
        }
      }
    }
  }

  Future<Response> updateStatus(String id, {required String status, String? note, String? artisanId}) {
    final payload = {'status': status, if (note != null) 'note': note, if (artisanId != null) 'artisanId': artisanId};
    return _dio.put('/api/admin/orders/$id/status', data: payload).catchError((e) async {
      if (e is DioException && e.response?.statusCode == 404) {
        // fallback to requests status endpoint
        return await _dio.put('/api/admin/requests/$id/status', data: payload);
      }
      if (e is DioException) throw mapDioException(e);
      throw e;
    });
  }

  Future<Response> cancel(String id, {String? reason, String? note}) async {
    final payload = {'reason': reason, 'note': note};
    try {
      return await _dio.put('/api/admin/orders/$id/cancel', data: payload);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          return await _dio.put('/api/admin/requests/$id/cancel', data: payload);
        } catch (_) {
          // fall through to status update
        }
      }
      return await updateStatus(id, status: 'cancelled', note: note);
    }
  }

  Future<Response> close(String id, {String? note}) async {
    final payload = {'status': 'closed', if (note != null) 'note': note};
    try {
      return await _dio.put('/api/admin/orders/$id/close', data: payload);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        try {
          return await _dio.put('/api/admin/requests/$id/close', data: payload);
        } catch (_) {
          // fall through to status update
        }
      }
      return await updateStatus(id, status: 'closed', note: note);
    }
  }

  Future<Response> messages(String id) => _dio.get('/api/admin/orders/$id/messages');

  Future<Response> sendMessage(String id, {required String message}) =>
      _dio.post('/api/admin/orders/$id/messages', data: {'message': message});

  bool _isError(int? status) => status != null && status >= 400;
}
