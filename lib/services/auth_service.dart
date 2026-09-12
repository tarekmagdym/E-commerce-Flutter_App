import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/auth_result_model.dart';

/// Talks to backend/routes/authRoutes.js. Each method throws
/// [ApiException] on failure — callers (AuthProvider) catch it and
/// surface `.message` to the UI.
class AuthService {
  final ApiClient _client = ApiClient();

  /// POST /api/auth/register  { fullName, email, password }
  Future<AuthResultModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final res = await _client.post(ApiEndpoints.register, body: {
      'fullName': fullName,
      'email': email,
      'password': password,
    });
    return AuthResultModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// POST /api/auth/login  { email, password }
  Future<AuthResultModel> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.post(ApiEndpoints.login, body: {
      'email': email,
      'password': password,
    });
    return AuthResultModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// POST /api/auth/forgot-password  { email }
  /// Backend always responds success:true (even for unknown emails) to
  /// avoid leaking which addresses are registered — an OTP is emailed
  /// only if the account exists.
  Future<String> forgotPassword({required String email}) async {
    final res = await _client.post(ApiEndpoints.forgotPassword, body: {
      'email': email,
    });
    return res.message;
  }

  /// POST /api/auth/verify-reset-code  { email, code }
  /// Returns a short-lived resetToken to pass into resetPassword().
  Future<String> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final res = await _client.post(ApiEndpoints.verifyResetCode, body: {
      'email': email,
      'code': code,
    });
    final resetToken = res.raw['resetToken'];
    if (resetToken == null || resetToken.toString().isEmpty) {
      throw ApiException('Server did not return a reset token');
    }
    return resetToken.toString();
  }

  /// POST /api/auth/reset-password  { email, resetToken, newPassword }
  Future<String> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final res = await _client.post(ApiEndpoints.resetPassword, body: {
      'email': email,
      'resetToken': resetToken,
      'newPassword': newPassword,
    });
    return res.message;
  }

  /// POST /api/auth/google  { idToken }  (requires google_sign_in package
  /// + GOOGLE_CLIENT_ID configured on the backend)
  Future<AuthResultModel> googleLogin({required String idToken}) async {
    final res = await _client.post(ApiEndpoints.googleLogin, body: {
      'idToken': idToken,
    });
    return AuthResultModel.fromJson(res.data as Map<String, dynamic>);
  }

  /// POST /api/auth/microsoft  { accessToken }  (requires an MSAL package
  /// on the client)
  Future<AuthResultModel> microsoftLogin({required String accessToken}) async {
    final res = await _client.post(ApiEndpoints.microsoftLogin, body: {
      'accessToken': accessToken,
    });
    return AuthResultModel.fromJson(res.data as Map<String, dynamic>);
  }
}
