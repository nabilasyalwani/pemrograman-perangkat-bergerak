import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:eyexaminer_refactor/services/notification_service.dart';

class CommonApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      responseType: ResponseType.json,
    ),
  );

  static Future<T?> post<T>(
    String url,
    Map<String, dynamic> data, {
    required T Function(dynamic) parser,
    bool isFormData = false,
  }) async {
    try {
      final formData = isFormData ? FormData.fromMap(data) : null;

      final response = await _dio.post(
        url,
        data: isFormData ? formData : data,
        options: Options(
          contentType: isFormData ? 'multipart/form-data' : 'application/json',
        ),
      );

      if (response.statusCode == 200) {
        return parser(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleError('POST', url, e);
      return null;
    }
  }

  static Future<T?> get<T>(
    String url, {
    required T Function(dynamic) parser,
  }) async {
    try {
      final response = await _dio.get(url);
      if (response.statusCode == 200) {
        return parser(response.data);
      }
      return null;
    } on DioException catch (e) {
      _handleError('GET', url, e);
      return null;
    }
  }

  static void _handleError(String method, String url, DioException error) {
    final message = error.response?.statusCode == null
        ? 'Network error: $method $url'
        : 'API Error (${error.response?.statusCode}): ${error.message}';

    // NotificationService.createNotification(
    //   id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
    //   title: 'API Error',
    //   body: message,
    // );
    debugPrint(message);
  }
}
