import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_storage.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Central place screens talk to for register/login/logout/password-reset.
/// Wrap the app with ChangeNotifierProvider(create: (_) => AuthProvider())
/// and read it with `context.watch<AuthProvider>()` /
/// `context.read<AuthProvider>()`.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.unknown;
  UserModel? currentUser;

  bool isLoading = false;
  String? errorMessage;

  /// Set by [verifyResetCode] on success. The verify-code screen reads
  /// this to pass it into the reset-password route's arguments.
  String? resetToken;

  /// Call once at startup (e.g. in main() or a splash screen) to
  /// restore a previous session from local storage.
  Future<void> loadSession() async {
    final token = await LocalStorage.getToken();
    final userJson = await LocalStorage.getUser();
    if (token != null && token.isNotEmpty && userJson != null) {
      currentUser = UserModel.fromJson(userJson);
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> _runAuthCall(Future<void> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Something went wrong. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
  }) {
    return _runAuthCall(() async {
      final result = await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
      );
      await _persistSession(result.token, result.user);
    });
  }

  Future<bool> login({required String email, required String password}) {
    return _runAuthCall(() async {
      final result = await _authService.login(email: email, password: password);
      await _persistSession(result.token, result.user);
    });
  }

  /// Step 1 of "forgot password": sends the OTP email.
  Future<bool> forgotPassword({required String email}) {
    return _runAuthCall(() async {
      await _authService.forgotPassword(email: email);
    });
  }

  /// Step 2: verifies the OTP the user received by email. On success,
  /// [resetToken] is populated for the caller to forward to the
  /// reset-password screen.
  Future<bool> verifyResetCode({required String email, required String code}) {
    return _runAuthCall(() async {
      resetToken = await _authService.verifyResetCode(email: email, code: code);
    });
  }

  /// Step 3: sets the new password using the token from step 2.
  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) {
    return _runAuthCall(() async {
      await _authService.resetPassword(
        email: email,
        resetToken: resetToken,
        newPassword: newPassword,
      );
      this.resetToken = null;
    });
  }

  Future<void> _persistSession(String token, UserModel user) async {
    await LocalStorage.saveToken(token);
    await LocalStorage.saveUser(user.toJson());
    currentUser = user;
    status = AuthStatus.authenticated;
  }

  Future<void> logout() async {
    await LocalStorage.clearSession();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }
}
