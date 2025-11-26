import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';

class ProfileService {
  final Dio _dio = ApiClient().dio;

  Future<Response> me() async {
    try {
      return await _dio.get('/api/admin/me');
    } on DioException catch (e) {
      // Fallback to verify-role when /me is not implemented
      if (e.response?.statusCode == 404) {
        return await _dio.get('/api/admin/verify-role');
      }
      rethrow;
    }
  }
}
