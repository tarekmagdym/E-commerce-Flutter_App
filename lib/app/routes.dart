import 'package:flutter/material.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/verify_reset_code_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/auth/reset_success_screen.dart';
import '../features/user/home/home_screen.dart';
import '../features/user/categories/categories_screen.dart';
import '../features/user/profile/profile_screen.dart';
import '../features/user/cart/cart_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String verifyResetCode = '/verify-reset-code';
  static const String resetPassword = '/reset-password';
  static const String resetSuccess = '/reset-success';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String profile = '/profile';
  static const String cart = '/cart';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case register:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const RegisterScreen(),
        );

      case forgotPassword:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ForgotPasswordScreen(),
        );

      case verifyResetCode:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => VerifyResetCodeScreen(
            email: args['email'] as String? ?? '',
          ),
        );

      case resetPassword:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ResetPasswordScreen(
            email: args['email'] as String? ?? '',
            resetToken: args['resetToken'] as String? ?? '',
          ),
        );

      case resetSuccess:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ResetSuccessScreen(),
        );

      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case categories:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => CategoriesScreen(
            initialCategoryId: args['categoryId'] as String?,
          ),
        );

      case profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );
      case cart:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const CartScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );
    }
  }
}