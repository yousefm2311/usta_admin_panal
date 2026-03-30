import 'dart:async';

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

import '../../widgets/modules/auth/controllers/auth_controller.dart';
import '../../widgets/modules/auth/services/auth_service.dart';
import 'token_storage.dart';
class AuthInterceptor extends Interceptor {
  final Dio dio;
  final TokenStorage tokenStorage;
  final AuthService authService;

  bool _isRefreshing = false;
  final List<Completer<void>> _refreshWaiters = [];

  AuthInterceptor(this.dio, this.tokenStorage, this.authService);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final token = tokenStorage.token;
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {}
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final res = err.response;
    final status = res?.statusCode;
    final options = err.requestOptions;
    if (status != 401) {
      return super.onError(err, handler);
    }
    final isAuthEndpoint = options.path.contains('/refresh-token') ||
        options.path.contains('/login') ||
        options.path.contains('/logout');
    if (isAuthEndpoint) {
      await _handleRefreshFailure(err, callLogoutApi: false);
      return handler.reject(err);
    }
    final refreshToken = tokenStorage.refreshToken;
    if (refreshToken == null || refreshToken.isEmpty) {
      await _handleRefreshFailure(err, callLogoutApi: false);
      return handler.reject(err);
    }
    if (_isRefreshing) {
      final completer = Completer<void>();
      _refreshWaiters.add(completer);
      try {
        await completer.future;
        final clonedRequest = await _retryRequest(options);
        return handler.resolve(clonedRequest);
      } catch (e) {
        return handler.reject(err);
      }
    }
    _isRefreshing = true;
    try {
      final tokens = await authService.refresh(refreshToken);
      if (tokens.token.isNotEmpty) {
        await tokenStorage.saveTokens(tokens.token, refreshToken: tokens.refreshToken);
      }
      for (final w in _refreshWaiters) {
        if (!w.isCompleted) w.complete();
      }
      _refreshWaiters.clear();
      _isRefreshing = false;
      final retryResp = await _retryRequest(options);
      return handler.resolve(retryResp);
    } catch (e) {
      await _handleRefreshFailure(err, callLogoutApi: false);
      for (final w in _refreshWaiters) {
        if (!w.isCompleted) w.completeError(e);
      }
      _refreshWaiters.clear();
      _isRefreshing = false;
      return handler.reject(err);
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final opts = Options(method: requestOptions.method, headers: Map.from(requestOptions.headers));
    final token = tokenStorage.token;
    if (token != null && token.isNotEmpty) {
      opts.headers ??= {};
      opts.headers!['Authorization'] = 'Bearer $token';
    }
    final cloned = await dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: opts,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
    return cloned;
  }

  Future<void> _handleRefreshFailure(DioException err, {bool callLogoutApi = true}) async {
    try {
      if (Get.isRegistered<AuthController>()) {
        await Get.find<AuthController>().logout(callApi: callLogoutApi);
      } else {
        await tokenStorage.clear();
        if (Get.isRegistered<GetInterface>()) Get.offAllNamed('/login');
      }
    } catch (_) {}
  }
}
