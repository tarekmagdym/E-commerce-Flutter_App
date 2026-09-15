import 'package:google_sign_in/google_sign_in.dart';

import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../core/storage/local_storage.dart';
import '../models/auth_result_model.dart';

/// Handles authentication-related operations. All methods are wired
/// to the real backend, including Google social login, which
/// authenticates natively then hands the resulting ID token to
/// POST /api/auth/google.
class AuthService {
  AuthService({ApiClient? apiClient}) : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  // GoogleSignIn.instance is a singleton that must be initialize()'d
  // exactly once — guard it here so it's safe to call loginWithGoogle()
  // from a fresh AuthService() each time (as login_screen.dart does).
  static bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: ApiEndpoints.googleServerClientId,
    );
    _googleInitialized = true;
  }

  /// Builds the same AuthResult shape login()/register() return, from
  /// a raw backend response — shared by the two social login methods
  /// below so LocalStorage and role handling stay in exactly one place.
  Future<AuthResult> _handleBackendAuthResponse(ApiResponse response) async {
    if (!response.success) {
      return AuthResult(success: false, message: response.message);
    }

    final data = response.data as Map<String, dynamic>? ?? {};
    final token = data['token'] as String?;
    final user = data['user'] as Map<String, dynamic>?;
    final role = user?['role'] as String? ?? 'user';

    if (token == null) {
      return const AuthResult(success: false, message: 'Unexpected response from server');
    }

    await LocalStorage.saveToken(token);
    await LocalStorage.saveRole(role);

    return AuthResult(success: true, message: response.message, token: token, role: role);
  }

  /// POST /api/auth/login — real backend call.
  /// Body: { email, password }
  /// Response: { success, message, data: { token, user: { role, ... } } }
  Future<AuthResult> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: {'email': email, 'password': password},
    );
    return _handleBackendAuthResponse(response);
  }

  /// POST /api/auth/register
  /// Body: { fullName, email, password }
  /// Response: { success, message, data: { token, user: { role, ... } } }
  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      body: {'fullName': fullName, 'email': email, 'password': password},
    );
    return _handleBackendAuthResponse(response);
  }

  /// POST /api/auth/forgot-password
  /// Body: { email }
  /// Response: { success, message } — always success:true even if the
  /// email isn't registered, by backend design (avoids leaking which
  /// emails have accounts).
  Future<AuthResult> forgotPassword({required String email}) async {
    final response = await _apiClient.post(
      ApiEndpoints.forgotPassword,
      body: {'email': email},
    );
    return AuthResult(success: response.success, message: response.message);
  }

  /// POST /api/auth/verify-reset-code
  /// Body: { email, code }
  /// Response: { success, message, resetToken } — resetToken is a
  /// top-level field here, not nested under `data` like login/register.
  Future<AuthResult> verifyResetCode({
    required String email,
    required String code,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.verifyResetCode,
      body: {'email': email, 'code': code},
    );

    if (!response.success) {
      return AuthResult(success: false, message: response.message);
    }

    final resetToken = response.raw['resetToken'] as String?;
    return AuthResult(success: true, message: response.message, resetToken: resetToken);
  }

  /// POST /api/auth/reset-password
  /// Body: { email, resetToken, newPassword }
  /// Response: { success, message }
  Future<AuthResult> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.resetPassword,
      body: {'email': email, 'resetToken': resetToken, 'newPassword': newPassword},
    );
    return AuthResult(success: response.success, message: response.message);
  }

  /// Real Google Sign-In. Gets an ID token natively, then POSTs it to
  /// POST /api/auth/google, which verifies it against GOOGLE_CLIENT_ID.
  Future<AuthResult> loginWithGoogle() async {
    try {
      await _ensureGoogleInitialized();
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;

      if (idToken == null) {
        return const AuthResult(success: false, message: 'Could not get a Google ID token');
      }

      final response = await _apiClient.post(
        ApiEndpoints.googleLogin,
        body: {'idToken': idToken},
      );
      return _handleBackendAuthResponse(response);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const AuthResult(success: false, message: 'Google sign-in was cancelled');
      }
      return AuthResult(success: false, message: 'Google sign-in failed: ${e.description}');
    }
  }

}