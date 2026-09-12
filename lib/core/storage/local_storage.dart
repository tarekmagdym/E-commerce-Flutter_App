import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around SharedPreferences for the pieces of state that
/// must survive an app restart: the JWT and the logged-in user's JSON.
///
/// Add to pubspec.yaml if not already present:
///   shared_preferences: ^2.2.3
class LocalStorage {
  LocalStorage._();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  static SharedPreferences? _prefs;

  /// Call once, e.g. in main() before runApp(), or lazily the first
  /// time any method below is used.
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> get _instance async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  static Future<void> saveToken(String token) async {
    final prefs = await _instance;
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await _instance;
    return prefs.getString(_tokenKey);
  }

  static Future<void> saveUser(Map<String, dynamic> userJson) async {
    final prefs = await _instance;
    await prefs.setString(_userKey, jsonEncode(userJson));
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await _instance;
    final raw = prefs.getString(_userKey);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  /// Clears the token and cached user — call this on logout.
  static Future<void> clearSession() async {
    final prefs = await _instance;
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
