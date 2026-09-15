import 'dart:convert';
import 'package:http/http.dart' as http;
import '../storage/local_storage.dart';
import 'api_endpoints.dart';

/// Thin wrapper around the real HTTP layer. Every backend call in the
/// app should go through this — not `http` directly — so the base
/// URL, auth header, and response parsing stay in one place.
class ApiClient {
  const ApiClient();

  Future<ApiResponse> post(
      String path, {
        Map<String, dynamic>? body,
        bool requiresAuth = false,
      }) async {
    try {
      final headers = await _buildHeaders(requiresAuth);
      final response = await http
          .post(
        Uri.parse('${ApiEndpoints.baseUrl}$path'),
        headers: headers,
        body: jsonEncode(body ?? {}),
      )
          .timeout(const Duration(seconds: 15));
      return _parse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Could not reach the server. Check your connection and try again.',
      );
    }
  }

  Future<ApiResponse> get(String path, {bool requiresAuth = false}) async {
    try {
      final headers = await _buildHeaders(requiresAuth);
      final response = await http
          .get(Uri.parse('${ApiEndpoints.baseUrl}$path'), headers: headers)
          .timeout(const Duration(seconds: 15));
      return _parse(response);
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: 0,
        message: 'Could not reach the server. Check your connection and try again.',
      );
    }
  }

  Future<Map<String, String>> _buildHeaders(bool requiresAuth) async {
    final headers = {'Content-Type': 'application/json'};
    if (requiresAuth) {
      final token = await LocalStorage.getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  ApiResponse _parse(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      json = {};
    }

    // Matches this backend's consistent { success, message, data? }
    // response shape (seen in authController.js for most endpoints).
    final httpOk = response.statusCode >= 200 && response.statusCode < 300;
    return ApiResponse(
      success: httpOk && (json['success'] as bool? ?? httpOk),
      statusCode: response.statusCode,
      message: json['message'] as String? ?? (httpOk ? 'Success' : 'Something went wrong'),
      data: json['data'],
      raw: json,
    );
  }
}

/// Normalized result of an API call.
class ApiResponse {
  const ApiResponse({
    required this.success,
    required this.statusCode,
    required this.message,
    this.data,
    this.raw = const {},
  });

  final bool success;
  final int statusCode;
  final String message;
  final dynamic data;

  /// The full decoded response body. Most endpoints nest everything
  /// useful under [data], but a few (e.g. verify-reset-code) put
  /// fields at the top level — use this to reach those.
  final Map<String, dynamic> raw;
}