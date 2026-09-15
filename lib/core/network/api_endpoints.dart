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
  static const String googleServerClientId = 'YOUR_WEB_CLIENT_ID.apps.googleusercontent.com';

  static const String adminDashboardStats = '/admin/dashboard/stats';
  static const String adminDashboardSalesChart = '/admin/dashboard/sales-chart';
  static const String adminDashboardRecentOrders = '/admin/dashboard/recent-orders';
  static const String products = '/products';
  static const String bestSellers = '/products/best-sellers';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String cartItems = '/cart/items';
  static const String userAddresses = '/users/me/addresses';
  static const String paymentMethods = '/payment-methods';
  static const String orders = '/orders';
  static const String adminOrders = '/admin/orders';
}