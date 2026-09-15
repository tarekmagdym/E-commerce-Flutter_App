import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for simple key-value
/// persistence. Currently used for the auth token and role; add more
/// keys here as needed rather than reaching for SharedPreferences
/// directly elsewhere in the app.
class LocalStorage {
  LocalStorage._();

  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'auth_role';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_roleKey, role);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  /// Clears the stored session. Call this on logout.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
  }
}