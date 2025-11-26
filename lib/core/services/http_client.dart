import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../constants/app_config.dart';
import 'api_exceptions.dart';
import 'token_storage.dart';

class HttpClient {
  final Dio dio;
  final TokenStorage _tokenStorage;
  HttpClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? Get.find<TokenStorage>(),
        dio = Dio(
          BaseOptions(
            baseUrl: AppConfig.baseUrl,
            connectTimeout: AppConfig.connectTimeout,
            receiveTimeout: AppConfig.receiveTimeout,
            responseType: ResponseType.json,
          ),
        ) {
    dio.interceptors.add(_AuthInterceptor(_tokenStorage));
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
  final TokenStorage tokenStorage;
  _AuthInterceptor(this.tokenStorage);

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
    if (err.response?.statusCode == 401) {
      // Auto logout hook: clear token and redirect if needed.
      await tokenStorage.clear();
      // Optional: Get.offAllNamed('/login');
    }
    super.onError(err, handler);
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
