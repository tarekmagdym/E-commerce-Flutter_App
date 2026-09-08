import '../models/auth_result_model.dart';

/// Handles authentication-related operations.
///
/// Currently mocked with local delays so the UI is fully testable
/// without a backend. Each method below documents the exact Node.js
/// endpoint it will call once wired up — only the body of each
/// method needs to change; callers (the screens) never will.
class AuthService {
  // TODO: inject ApiClient here once the backend is connected:
  // final ApiClient _apiClient;
  // AuthService(this._apiClient);

  Future<AuthResult> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    // Real call will be:
    // final res = await _apiClient.post(ApiEndpoints.register, body: {
    //   'fullName': fullName, 'email': email, 'password': password,
    // });
    await Future.delayed(const Duration(seconds: 1));
    return const AuthResult(
      success: true,
      message: 'Account created successfully',
    );
  }

  Future<AuthResult> forgotPassword({required String email}) async {
    // Real call will be:
    // final res = await _apiClient.post(ApiEndpoints.forgotPassword, body: {'email': email});
    await Future.delayed(const Duration(seconds: 1));
    return const AuthResult(
      success: true,
      message: 'Verification code sent to your email',
    );
  }

  Future<AuthResult> verifyResetCode({
    required String email,
    required String code,
  }) async {
    // Real call will be:
    // final res = await _apiClient.post(ApiEndpoints.verifyResetCode, body: {'email': email, 'code': code});
    await Future.delayed(const Duration(seconds: 1));
    if (code.length != 6) {
      return const AuthResult(success: false, message: 'Invalid verification code');
    }
    return const AuthResult(
      success: true,
      message: 'Code verified',
      resetToken: 'mock-reset-token',
    );
  }

  Future<AuthResult> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    // Real call will be:
    // final res = await _apiClient.post(ApiEndpoints.resetPassword, body: {'email': email, 'resetToken': resetToken, 'newPassword': newPassword});
    await Future.delayed(const Duration(seconds: 1));
    return const AuthResult(success: true, message: 'Password reset successfully');
  }

  /// Mock social login. Swap for real Google Sign-In later —
  /// e.g. via `google_sign_in` package, then POST the resulting
  /// ID token to your backend for verification.
  Future<AuthResult> loginWithGoogle() async {
    // Real flow will be:
    // final googleUser = await GoogleSignIn().signIn();
    // final res = await _apiClient.post(ApiEndpoints.googleLogin, body: {'idToken': ...});
    await Future.delayed(const Duration(milliseconds: 900));
    return const AuthResult(
      success: true,
      message: 'Logged in with Google successfully',
    );
  }

  /// Mock social login. Swap for real Microsoft Sign-In later —
  /// e.g. via `msal_auth` / `aad_oauth`, then POST the resulting
  /// token to your backend for verification.
  Future<AuthResult> loginWithMicrosoft() async {
    // Real flow will be:
    // final msalResult = await msalAuth.acquireToken(...);
    // final res = await _apiClient.post(ApiEndpoints.microsoftLogin, body: {'accessToken': ...});
    await Future.delayed(const Duration(milliseconds: 900));
    return const AuthResult(
      success: true,
      message: 'Logged in with Microsoft successfully',
    );
  }
}