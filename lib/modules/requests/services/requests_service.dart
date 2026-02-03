import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/api_exceptions.dart';

class RequestsService {
  final ApiClient _client = ApiClient();
  Dio get _dio => _client.dio;

  Future<Response> fetchRequests({String? status}) {
    if (status == null || status.isEmpty) {
      return _client.safe(() => _dio.get('/api/admin/requests'));
    }

    return _client
        .safe(
          () => _dio.get(
            '/api/admin/requests',
            queryParameters: {'status': status},
          ),
        )
        .catchError((error) {
      if (error is ApiException &&
          (error.statusCode == 404 || error.statusCode == 400)) {
        return _client.safe(
          () => _dio.get(
            '/api/admin/requests/filter',
            queryParameters: {'status': status},
          ),
        );
      }
      throw error;
    });
  }

  Future<Response> fetchDetails(String id) =>
      _client.safe(() => _dio.get('/api/admin/requests/$id'));

  Future<Response> timeline(String id) =>
      _client.safe(() => _dio.get('/api/admin/requests/$id/timeline'));

  Future<Response> close(String id, {required String status, String? note}) =>
      _client.safe(
        () => _dio.put(
          '/api/admin/requests/$id/close',
          data: {'status': status, if (note != null) 'note': note},
        ),
      );

  Future<Response> cancel(String id, {String? reason, String? note}) async {
    final payload = {
      'status': 'canceled',
      if (note != null) 'note': note,
      if (reason != null) 'reason': reason,
    };
    try {
      return await _client.safe(
        () => _dio.put('/api/admin/requests/$id/close', data: payload),
      );
    } catch (_) {
      return await _client.safe(
        () => _dio.put('/api/admin/requests/$id/cancel', data: payload),
      );
    }
  }

  Future<Response> addTimeline(
    String id, {
    required String status,
    String? note,
  }) async {
    final payload = {'status': status, if (note != null) 'note': note};
    try {
      final res = await _client.safe(
        () => _dio.post('/api/admin/requests/$id/timeline', data: payload),
      );
      if (_isError(res.statusCode)) throw Exception('timeline not available');
      return res;
    } catch (_) {
      // fallback to status endpoint if timeline not found
      final res = await updateStatus(id, status: status, note: note);
      if (_isError(res.statusCode)) throw Exception('timeline not available');
      return res;
    }
  }

  bool _isError(int? status) => status != null && status >= 400;

  Future<Response> messages(String id) =>
      _client.safe(() => _dio.get('/api/admin/requests/$id/messages'));

  Future<Response> sendMessage(String id, {required String message}) =>
      _client.safe(
        () => _dio.post(
          '/api/admin/requests/$id/messages',
          data: {'message': message},
        ),
      );

  Future<Response> updateStatus(
    String id, {
    required String status,
    String? note,
  }) => _client.safe(
    () => _dio.put(
      '/api/admin/requests/$id/status',
      data: {'status': status, if (note != null) 'note': note},
    ),
  );

  Future<Response> delete(String id) =>
      _client.safe(() => _dio.delete('/api/admin/requests/$id'));

  Future<Response> expireStale({int? limit, String? before}) {
    final payload = <String, dynamic>{
      if (limit != null) 'limit': limit,
      if (before != null) 'before': before,
    };
    return _client.safe(
      () => _dio.post('/api/admin/requests/expire-stale', data: payload),
    );
  }

  Future<Response> autoConfirm({int? limit, String? before}) {
    final payload = <String, dynamic>{
      if (limit != null) 'limit': limit,
      if (before != null) 'before': before,
    };
    return _client.safe(
      () => _dio.post('/api/admin/requests/auto-confirm', data: payload),
    );
  }
}
