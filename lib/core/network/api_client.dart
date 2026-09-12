import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'api_endpoints.dart';
import '../storage/local_storage.dart';

/// Thrown whenever the backend responds with `success: false`, a non-2xx
/// status code, or the request fails outright (timeout / no connection).
/// Screens should catch this and show [message] to the user.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Every backend response follows the shape:
///   { "success": bool, "message": string, "data"?: any, ...extraFields }
/// This wraps that so callers can read `.data` (or any extra top-level
/// field, like `resetToken` on /verify-reset-code) without re-parsing.
class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic> raw;

  ApiResponse({required this.success, required this.message, required this.raw});

  dynamic get data => raw['data'];

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    return ApiResponse(
      success: json['success'] == true,
      message: (json['message'] ?? '').toString(),
      raw: json,
    );
  }
}

/// Thin HTTP client around the `http` package. Adds the base URL,
/// JSON headers, the `Authorization: Bearer <token>` header when a
/// token is stored, and turns backend error responses into
/// [ApiException] so callers only ever deal with success cases.
///
/// Add to pubspec.yaml if not already present:
///   http: ^1.2.0
class ApiClient {
  static const Duration _timeout = Duration(seconds: 20);

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final token = await LocalStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Uri _uri(String path) => Uri.parse('${ApiEndpoints.baseUrl}$path');

  ApiResponse _handle(http.Response response) {
    Map<String, dynamic> body;
    try {
      body = response.body.isEmpty
          ? <String, dynamic>{}
          : jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Unexpected response from server (${response.statusCode})',
        statusCode: response.statusCode,
      );
    }

    final parsed = ApiResponse.fromJson(body);

    if (response.statusCode < 200 || response.statusCode >= 300 || !parsed.success) {
      throw ApiException(
        parsed.message.isNotEmpty ? parsed.message : 'Something went wrong',
        statusCode: response.statusCode,
      );
    }

    return parsed;
  }

  ApiException _wrapError(Object err) {
    if (err is ApiException) return err;
    if (err is SocketException) {
      return ApiException(
          'Could not reach the server. Check your internet connection and that ApiEndpoints.baseUrl is correct.');
    }
    return ApiException('Network error: $err');
  }

  Future<ApiResponse> get(String path, {bool auth = false}) async {
    try {
      final response = await http
          .get(_uri(path), headers: await _headers(auth: auth))
          .timeout(_timeout);
      return _handle(response);
    } catch (err) {
      throw _wrapError(err);
    }
  }

  Future<ApiResponse> post(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    try {
      final response = await http
          .post(
            _uri(path),
            headers: await _headers(auth: auth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
      return _handle(response);
    } catch (err) {
      throw _wrapError(err);
    }
  }

  Future<ApiResponse> put(String path, {Map<String, dynamic>? body, bool auth = false}) async {
    try {
      final response = await http
          .put(
            _uri(path),
            headers: await _headers(auth: auth),
            body: jsonEncode(body ?? {}),
          )
          .timeout(_timeout);
      return _handle(response);
    } catch (err) {
      throw _wrapError(err);
    }
  }

  Future<ApiResponse> delete(String path, {bool auth = false}) async {
    try {
      final response = await http
          .delete(_uri(path), headers: await _headers(auth: auth))
          .timeout(_timeout);
      return _handle(response);
    } catch (err) {
      throw _wrapError(err);
    }
  }
}
