import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../constants/app_config.dart';
import 'api_exceptions.dart';
import 'token_storage.dart';
import '../../modules/auth/services/auth_service.dart';

class HttpClient {
  final Dio dio;
  final TokenStorage _tokenStorage;
  final AuthService _authService;
  HttpClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? Get.find<TokenStorage>(),
        dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            responseType: ResponseType.json,
          ),
        ),
        _authService = AuthService(
          dio: Dio(
            BaseOptions(
              baseUrl: AppConfig.baseUrl,
              connectTimeout: AppConfig.connectTimeout,
              receiveTimeout: AppConfig.receiveTimeout,
              responseType: ResponseType.json,
            ),
          ),
        ) {
    dio.interceptors.add(_AuthInterceptor(dio, _tokenStorage, _authService));
    dio.interceptors.add(_LoggingInterceptor());
  }

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? query}) async {
    await _ensureOnline();
    try {
      return await dio.get<T>(path, queryParameters: query);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> post<T>(String path, {dynamic data, Map<String, dynamic>? query}) async {
    await _ensureOnline();
    try {
      return await dio.post<T>(path, data: data, queryParameters: query);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> put<T>(String path, {dynamic data, Map<String, dynamic>? query}) async {
    await _ensureOnline();
    try {
      return await dio.put<T>(path, data: data, queryParameters: query);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  Future<Response<T>> delete<T>(String path, {dynamic data, Map<String, dynamic>? query}) async {
    await _ensureOnline();
    try {
      return await dio.delete<T>(path, data: data, queryParameters: query);
    } on DioException catch (e) {
      throw _mapError(e);
    }
  }

  ApiException _mapError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
      return TimeoutException('Request timed out');
    }
    if (e.error is SocketException) {
      return NetworkException('No internet connection');
    }
    final status = e.response?.statusCode;
    if (status == 401) return UnauthorizedException('Unauthorized');
    if (status != null && status >= 500) {
      return ServerException('Server error', statusCode: status);
    }
    final message = e.response?.data is Map<String, dynamic>
        ? (e.response?.data['message']?.toString() ?? 'Request error')
        : e.message ?? 'Request error';
    return ApiException(message, statusCode: status);
  }

  Future<void> _ensureOnline() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw NetworkException('No internet connection');
    }
  }
}

class _AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final AuthService authService;
  bool _refreshing = false;
  _AuthInterceptor(this.dio, this.tokenStorage, this.authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = tokenStorage.token;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final status = err.response?.statusCode;
    final path = err.requestOptions.path;
    final refreshToken = tokenStorage.refreshToken;
    if (status == 401 && refreshToken != null && refreshToken.isNotEmpty && !_refreshing && !path.contains('refresh-token')) {
      _refreshing = true;
      try {
        final newToken = await _refreshAccessToken(refreshToken);
        if (newToken != null && newToken.isNotEmpty) {
          // retry original request with new token
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newToken';
          final cloneResponse = await dio.fetch(opts);
          _refreshing = false;
          return handler.resolve(cloneResponse);
        }
      } catch (_) {
        // fallthrough to clear tokens
      }
      _refreshing = false;
      await tokenStorage.clear();
    }
    super.onError(err, handler);
  }

  Future<String?> _refreshAccessToken(String refreshToken) async {
    try {
      final tokens = await authService.refresh(refreshToken);
      if (tokens.token.isNotEmpty) {
        await tokenStorage.saveTokens(tokens.token, refreshToken: tokens.refreshToken ?? refreshToken);
      }
      return tokens.token;
    } catch (e) {
      return null;
    }
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('--> ${options.method} ${options.uri}');
      debugPrint('Headers: ${options.headers}');
      debugPrint('Data: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('<-- ${response.statusCode} ${response.requestOptions.uri}');
      debugPrint('Response: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      debugPrint('ERROR[${err.response?.statusCode}] => ${err.requestOptions.uri}');
      debugPrint(err.message);
    }
    super.onError(err, handler);
  }
}
