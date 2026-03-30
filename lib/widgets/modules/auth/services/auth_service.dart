import 'package:dio/dio.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/api_exceptions.dart';

class AuthTokens {
  final String token;
  final String? refreshToken;
  AuthTokens(this.token, {this.refreshToken});
}

class AuthService {
  final Dio _dio;
  AuthService({Dio? dio}) : _dio = dio ?? ApiClient().dio;

  Future<AuthTokens> login({required String email, required String password}) async {
    try {
      final res = await _dio.post('/api/admin/login', data: {
        'email': email,
        'password': password,
      });
      final map = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : <String, dynamic>{};
      final data = map['data'] is Map<String, dynamic> ? map['data'] as Map<String, dynamic> : <String, dynamic>{};
      final token = map['token']?.toString() ?? data['token']?.toString() ?? map['accessToken']?.toString();
      final refreshToken = map['refreshToken']?.toString() ??
          data['refreshToken']?.toString() ??
          map['refresh_token']?.toString() ??
          data['refresh_token']?.toString();
      if (token == null || token.isEmpty) {
        throw ApiException('Token missing in response');
      }
      return AuthTokens(token, refreshToken: refreshToken);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<AuthTokens> refresh(String refreshToken) async {
    try {
      final res = await _dio.post('/api/admin/refresh-token', data: {'refreshToken': refreshToken});
      final map = res.data is Map<String, dynamic> ? res.data as Map<String, dynamic> : <String, dynamic>{};
      final data = map['data'] is Map<String, dynamic> ? map['data'] as Map<String, dynamic> : <String, dynamic>{};
      final token = map['token']?.toString() ?? data['token']?.toString() ?? map['accessToken']?.toString();
      final newRefresh = map['refreshToken']?.toString() ??
          data['refreshToken']?.toString() ??
          map['refresh_token']?.toString() ??
          data['refresh_token']?.toString();
      if (token == null || token.isEmpty) {
        throw ApiException('Token missing in refresh response');
      }
      return AuthTokens(token, refreshToken: newRefresh ?? refreshToken);
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> verifyRole() async {
    try {
      await _dio.get('/api/admin/verify-role');
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> createAdmin({required String name, required String email, required String password, String role = 'admin'}) async {
    try {
      await _dio.post('/api/admin/create', data: {
        'name': name,
        'email': email,
        'password': password,
        'role': role,
      });
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    try {
      await _dio.put('/api/admin/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw mapDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/admin/logout');
    } on DioException catch (e) {
      throw mapDioException(e);
    } catch (_) {}
  }
}
