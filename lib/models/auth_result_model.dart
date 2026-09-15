class AuthResult {
  const AuthResult({
    required this.success,
    required this.message,
    this.resetToken,
    this.token,
    this.role,
  });

  final bool success;
  final String message;
  final String? resetToken;

  /// Populated by a real login — the JWT and the user's role
  /// ('user' | 'admin'), used to decide where to navigate.
  final String? token;
  final String? role;
}