/// Generic result returned by auth-related service calls.
/// [resetToken] is populated by verifyResetCode and consumed by
/// resetPassword — mirrors a typical short-lived reset-token flow.
class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.resetToken,
  });

  final bool success;
  final String message;
  final String? resetToken;
}