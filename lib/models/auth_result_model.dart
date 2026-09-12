import 'user_model.dart';

/// Mirrors the `data` object returned by /auth/register, /auth/login,
/// /auth/google and /auth/microsoft: { token, user }.
class AuthResultModel {
  final String token;
  final UserModel user;

  AuthResultModel({required this.token, required this.user});

  factory AuthResultModel.fromJson(Map<String, dynamic> json) {
    return AuthResultModel(
      token: (json['token'] ?? '').toString(),
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
