import 'dart:io';

import 'package:dio/dio.dart';
import 'package:get/get.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, statusCode: 401);
}

class ServerException extends ApiException {
  ServerException(String message, {int? statusCode}) : super(message, statusCode: statusCode);
}

ApiException mapDioException(DioException e) {
  String t(String en, String ar) {
    final isAr = Get.locale?.languageCode == 'ar';
    return isAr ? ar : en;
  }

  // Connectivity and cancellation
  if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
    return TimeoutException(t('Request timed out', 'انتهت مهلة الاتصال'));
  }
  if (e.type == DioExceptionType.cancel) {
    return ApiException(t('Request cancelled', 'تم إلغاء الطلب'));
  }
  if (e.error is SocketException || e.type == DioExceptionType.connectionError) {
    return NetworkException(t('No internet connection', 'لا يوجد اتصال بالإنترنت'));
  }

  final status = e.response?.statusCode;
  if (status != null) {
    switch (status) {
      case 400:
        return ApiException(t('Bad request', 'طلب غير صالح'), statusCode: status);
      case 401:
        return UnauthorizedException(t('Session expired, please login again', 'انتهت الجلسة، يرجى تسجيل الدخول مجدداً'));
      case 403:
        return ApiException(t('You do not have permission to do this', 'ليست لديك صلاحية لتنفيذ هذا الإجراء'),
            statusCode: status);
      case 404:
        return ApiException(t('Resource not found', 'المورد غير موجود'), statusCode: status);
      case 409:
        return ApiException(t('Conflict, please try again', 'تعارض في الطلب، حاول مرة أخرى'), statusCode: status);
      case 422:
        return ApiException(t('Validation error, please check your input', 'خطأ في البيانات، يرجى المراجعة'),
            statusCode: status);
      case 429:
        return ApiException(t('Too many requests, please wait a moment', 'طلبات كثيرة، يرجى الانتظار قليلاً'),
            statusCode: status);
      default:
        if (status >= 500) {
          return ServerException(t('Server error, please try later', 'خطأ من الخادم، حاول لاحقاً'), statusCode: status);
        }
    }
  }

  String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message']?.toString() ?? data['error']?.toString();
    }
    if (data is String && data.isNotEmpty) return data;
    return null;
  }

  final serverMessage = _extractMessage(e.response?.data);
  final message = serverMessage?.isNotEmpty == true
      ? serverMessage!
      : (e.message?.isNotEmpty == true
          ? e.message!
          : t('Unexpected error occurred', 'حدث خطأ غير متوقع'));
  return ApiException(message, statusCode: status);
}
