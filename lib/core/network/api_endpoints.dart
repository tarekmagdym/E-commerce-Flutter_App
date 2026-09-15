class ApiEndpoints {
  ApiEndpoints._();

  // TODO: point this at your real Node.js backend when ready.
  static const String baseUrl = 'http://127.0.0.1:5000/api';
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyResetCode = '/auth/verify-reset-code';
  static const String resetPassword = '/auth/reset-password';
  static const String googleLogin = '/auth/google';
  static const String microsoftLogin = '/auth/microsoft';

  // TODO: paste the Google Cloud "Web application" OAuth client ID here
  // (the same value that goes into the backend's GOOGLE_CLIENT_ID).
  static const String googleServerClientId = '498493561220-4ag7kn100jikppssaih73llu1c2bmaah.apps.googleusercontent.com';
}