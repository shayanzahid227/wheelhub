// ignore_for_file: avoid_print, unnecessary_new, prefer_typing_uninitialized_variables, unnecessary_string_interpolations, curly_braces_in_flow_control_structures

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:hustler_syn/core/model/request_services.dart';
import 'package:hustler_syn/core/services/local_storagre_services.dart';
import 'package:hustler_syn/locator.dart';

class ApiServices {
  Map<String, dynamic> _sanitizedHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    final auth = sanitized["Authorization"]?.toString();
    if (auth != null) {
      final lower = auth.toLowerCase();
      if (lower.startsWith("bearer ")) {
        final token = auth.substring("Bearer ".length).trim();
        final masked = token.length <= 12
            ? "***"
            : "${token.substring(0, 6)}...${token.substring(token.length - 4)}";
        sanitized["Authorization"] = "Bearer $masked (len=${token.length})";
      }
    }
    return sanitized;
  }

  /// Launch and configure Dio instance
  Future<Dio> launchDio({bool isFormData = false}) async {
    final localStorage = locator<LocalStorageService>();

    final dio = Dio();

    // dio.interceptors.add(LogInterceptor(responseBody: true, requestBody: true));

    // Set default headers
    dio.options.headers = {
      "Accept": "application/json, */*",
      "User-Agent": "HustlerSyn/1.0.0 (Flutter)",
    };

    if (!isFormData) {
      dio.options.headers["Content-Type"] = "application/json; charset=utf-8";
    }

    // Safely add dynamic headers if data exists in local storage
    final token = localStorage.accessToken;
    if (token != null && token.isNotEmpty) {
      dio.options.headers["Authorization"] = "Bearer $token";
    }

    final userId = localStorage.userId;
    if (userId != null && userId.isNotEmpty) {
      dio.options.headers["user-id"] = userId;
    }

    // Backend expects "role" header for role-based routes (e.g. /api/client/profile). Use stored role or default to client when null.
    final role = localStorage.role;
    final roleValue = (role != null && role.isNotEmpty)
        ? '${role[0].toUpperCase()}${role.substring(1)}'
        : 'Client';
    dio.options.headers["role"] = roleValue;

    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.followRedirects = false;
    dio.options.validateStatus = (status) => status != null && status < 500;

    return dio;
  }

  /// GET
  Future<RequestResponse> get({
    required String url,
    Map<String, dynamic>? params,
    bool debugHeaders = false,
  }) async {
    final dio = await launchDio();

    try {
      if (kDebugMode && debugHeaders) {
        final headers = _sanitizedHeaders(
          Map<String, dynamic>.from(dio.options.headers),
        );
        debugPrint("---------------- API REQUEST ----------------");
        debugPrint("METHOD: GET");
        debugPrint("URL: $url");
        debugPrint("HEADERS: $headers");
        debugPrint("---------------------------------------------");
      }
      final response = await dio.get(url, queryParameters: params);
      if (response.statusCode == 200) {
        return RequestResponse(true, data: response.data);
      } else {
        return RequestResponse(
          false,
          message: _extractErrorMessage(response),
        );
      }
    } on DioException catch (e) {
      _logDioError(e);
      return RequestResponse(false, message: _handleError(e));
    } catch (e) {
      debugPrint("GET Request Error: $e");
      return RequestResponse(false, message: "Unexpected Error: $e");
    }
  }

  ///
  /// POST
  ///
  Future<RequestResponse> post({
    required String url,
    dynamic data,
    Map<String, dynamic>? params,
  }) async {
    final isFormData = data is FormData;
    final dio = await launchDio(isFormData: isFormData);

    try {
      if (kDebugMode) {
        print("---------------- API REQUEST ----------------");
        print("URL: $url");
        print("HEADERS: ${_sanitizedHeaders(Map<String, dynamic>.from(dio.options.headers))}");
        if (data is FormData) {
          print("BODY: FormData (multiple files/fields)");
        } else {
          print("BODY: $data");
        }
      }
      final response = await dio.post(url, data: data, queryParameters: params);

      if (kDebugMode) {
        print("---------------- API RESPONSE ---------------");
        print("STATUS: ${response.statusCode}");
        print("DATA: ${response.data}");
        print("---------------------------------------------");
      }

      if (response.statusCode == 200 || response.statusCode == 201) {
        return RequestResponse(true, data: response.data);
      } else {
        return RequestResponse(
          false,
          message: _extractErrorMessage(response),
        );
      }
    } on DioException catch (e) {
      _logDioError(e);
      return RequestResponse(false, message: _handleError(e));
    } catch (e) {
      debugPrint("POST Request Error: $e");
      return RequestResponse(false, message: "Unexpected Error: $e");
    }
  }

  /// PUT
  Future<RequestResponse> put({
    required String url,
    dynamic data,
  }) async {
    final isFormData = data is FormData;
    final dio = await launchDio(isFormData: isFormData);

    try {
      if (kDebugMode) print("API PUT URL => $url");
      final response = await dio.put(url, data: data);
      if (kDebugMode) print("PUT Response => ${response.data}");

      if (response.statusCode == 200) {
        return RequestResponse(true, data: response.data);
      } else {
        return RequestResponse(
          false,
          message: _extractErrorMessage(response),
        );
      }
    } on DioException catch (e) {
      _logDioError(e);
      return RequestResponse(false, message: _handleError(e));
    } catch (e) {
      debugPrint("PUT Request Error: $e");
      return RequestResponse(false, message: "Unexpected Error: $e");
    }
  }

  /// DELETE
  Future<RequestResponse> delete({
    required String url,
    Map<String, dynamic>? params,
  }) async {
    final dio = await launchDio();

    try {
      final response = await dio.delete(url, queryParameters: params);
      if (kDebugMode) print("DELETE Response => ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 204) {
        final msg = response.data is Map ? response.data['message'] : null;
        return RequestResponse(true, data: response.data, message: msg?.toString());
      } else {
        return RequestResponse(
          false,
          message: _extractErrorMessage(response),
        );
      }
    } on DioException catch (e) {
      _logDioError(e);
      return RequestResponse(false, message: _handleError(e));
    } catch (e) {
      debugPrint("DELETE Request Error: $e");
      return RequestResponse(false, message: "Unexpected Error: $e");
    }
  }

  // ✅ Handles DioException into readable messages
  String _handleError(DioException e) {
    if (e.type == DioExceptionType.connectionError) {
      return "Network connection failed. Please check your internet.";
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return "Connection timed out. Try again.";
    } else if (e.type == DioExceptionType.receiveTimeout) {
      return "Server took too long to respond.";
    } else if (e.type == DioExceptionType.badResponse) {
      final responseData = e.response?.data;
      if (responseData != null) {
        if (responseData != null) {
          if (responseData is Map) {
            if (responseData["error"] != null) {
              return responseData["error"].toString();
            } else if (responseData["message"] != null) {
              return responseData["message"].toString();
            }
          }
        }
      }
      return "Technical Error: ${e.response?.statusCode}. Please check server logs.";
    } else {
      return "An unexpected network error occurred.";
    }
  }

  void _logDioError(DioException e) {
    debugPrint("❌ Dio Error Type: ${e.type}");
    debugPrint("❌ Dio Error Message: ${e.message}");
    debugPrint("❌ Dio Error StackTrace: ${e.stackTrace}");
    debugPrint("❌ Dio Error Response: ${e.response?.data}");
  }

  String _extractErrorMessage(Response response) {
    String message = "Error: ${response.statusCode}";
    try {
      if (response.data != null) {
        if (response.data is Map) {
          if (response.data["error"] != null) {
            message = response.data["error"].toString();
          } else if (response.data["message"] != null) {
            message = response.data["message"].toString();
          }
        } else if (response.data is String &&
            response.data.toString().isNotEmpty) {
          // If it's HTML, we might want to trim it or just show a generic error
          if (response.data
              .toString()
              .toLowerCase()
              .contains("<!doctype html>")) {
            message = "Server error (HTML response). Check endpoint.";
          } else {
            message = response.data.toString();
          }
        }
      }
    } catch (e) {
      debugPrint("Error extracting message: $e");
    }
    return message;
  }
}
