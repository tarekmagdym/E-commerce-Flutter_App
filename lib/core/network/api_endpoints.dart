class ApiEndpoints {
  ApiEndpoints._();

  // TODO: point this at your real Node.js backend when ready.
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';
  static const String googleLogin = '/auth/google';
  static const String microsoftLogin = '/auth/microsoft';
}
