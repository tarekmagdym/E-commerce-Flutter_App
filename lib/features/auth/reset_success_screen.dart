import 'dart:async';
import 'package:flutter/material.dart';
import '../../app/routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';

/// Generic success screen used after Reset Password and Create Account.
/// [title] / [subtitle] default to the Reset Password copy so the
/// existing Forgot Password flow keeps working with no changes.
class ResetSuccessScreen extends StatefulWidget {
  const ResetSuccessScreen({
    super.key,
    this.title = AppStrings.resetSuccessTitle,
    this.subtitle = AppStrings.resetSuccessSubtitle,
  });

  final String title;
  final String subtitle;

  @override
  State<ResetSuccessScreen> createState() => _ResetSuccessScreenState();
}

class _ResetSuccessScreenState extends State<ResetSuccessScreen> {
  Timer? _autoRedirectTimer;

  @override
  void initState() {
    super.initState();
    _autoRedirectTimer = Timer(const Duration(seconds: 2), _goToLogin);
  }

  @override
  void dispose() {
    _autoRedirectTimer?.cancel();
    super.dispose();
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(context).popUntil(ModalRoute.withName(AppRoutes.login));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 30),
              ),
              const SizedBox(height: 24),
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                widget.subtitle,
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              CustomButton(
                label: AppStrings.backToLoginBtn,
                onPressed: _goToLogin,
              ),
            ],
          ),
        ),
      ),
    );
  }
}