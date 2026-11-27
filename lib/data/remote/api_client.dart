import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Shared Dio HTTP client with timeouts and clean error mapping.
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 12),
        responseType: ResponseType.json,
        headers: const <String, String>{
          'Accept': 'application/json',
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (Object obj) => debugPrint('[ApiClient] $obj'),
        ),
      );
    }
  }

  /// Performs a GET request to an absolute [url] and returns decoded JSON map.
  Future<Map<String, dynamic>> getJson(
      String url, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Unexpected HTTP status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('[ApiClient] Network failure for $url: ${e.message}');
      rethrow;
    }
  }

  /// Performs a GET request returning dynamic JSON (List or Map), used by Translation APIs.
  Future<dynamic> getDynamic(
      String url, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        url,
        queryParameters: queryParameters,
      );
      if (response.statusCode == 200) {
        return response.data;
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'Unexpected HTTP status: ${response.statusCode}',
      );
    } on DioException catch (e) {
      debugPrint('[ApiClient] Dynamic request failure for $url: ${e.message}');
      rethrow;
    }
  }
}