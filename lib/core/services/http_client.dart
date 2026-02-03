
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;

import '../../modules/auth/services/auth_service.dart';
import '../constants/app_config.dart';
import 'api_exceptions.dart';
import 'auth_interceptor.dart';
import 'token_storage.dart';

class HttpClient {
  final Dio dio;
  final TokenStorage _tokenStorage;
  final AuthService _authService;
  final Connectivity _connectivity = Connectivity();
  bool? _lastOnline;
  DateTime? _lastConnectivityCheck;
  static const Duration _connectivityCacheTtl = Duration(seconds: 5);
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
    dio.interceptors.add(AuthInterceptor(dio, _tokenStorage, _authService));
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

  ApiException _mapError(DioException e) => mapDioException(e);

  Future<void> _ensureOnline() async {
    final message = 'No internet connection'.tr;
    final now = DateTime.now();
    if (_lastOnline != null &&
        _lastConnectivityCheck != null &&
        now.difference(_lastConnectivityCheck!) < _connectivityCacheTtl) {
      if (_lastOnline == false) {
        throw NetworkException(message);
      }
      return;
    }
    final connectivity = await _connectivity.checkConnectivity();
    _lastOnline = _isOnline(connectivity);
    _lastConnectivityCheck = now;
    if (_lastOnline == false) {
      throw NetworkException(message);
    }
  }

  bool _isOnline(dynamic connectivity) {
    if (connectivity is ConnectivityResult) {
      return connectivity != ConnectivityResult.none;
    }
    if (connectivity is List<ConnectivityResult>) {
      return connectivity.any((result) => result != ConnectivityResult.none);
    }
    return true;
  }
}

// Old _AuthInterceptor removed in favor of new AuthInterceptor which provides
// single-refresh semantics, request queuing and stronger retry/error handling.

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
