import 'package:dio/dio.dart';

import '../../../core/services/api_client.dart';
import '../../../core/services/api_exceptions.dart';

class AuthService {
  final Dio _dio = ApiClient().dio;

  Future<String> login({required String email, required String password}) async {
    try {
      final res = await _dio.post('/api/admin/login', data: {
        'email': email,
        'password': password,
      });
      final token = res.data?['token']?.toString();
      if (token == null || token.isEmpty) {
        throw ApiException('Token missing in response');
      }
      return token;
    } on DioException catch (e) {
      rethrow;
    }
  }

  Future<void> verifyRole() async {
    await _dio.get('/api/admin/verify-role');
  }

  Future<void> createAdmin({required String name, required String email, required String password, String role = 'admin'}) async {
    await _dio.post('/api/admin/create', data: {
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
  }
}
