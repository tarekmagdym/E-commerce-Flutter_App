import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/widgets/custom_button.dart';
import '../../app/routes.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.splashBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 3),

              // Logo mark
              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.splashIconBg,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.shopping_bag,
                  color: Colors.white,
                  size: 44,
                ),
              ),

              const SizedBox(height: 28),

              // App name
              const Text(
                AppStrings.appName,
                style: TextStyle(
                  color: AppColors.textWhite,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              Text(
                AppStrings.splashTaglineLine1,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                AppStrings.splashTaglineLine2,
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 15,
                ),
              ),

              const Spacer(flex: 4),

              // Get Started button
              CustomButton(
                label: AppStrings.getStarted,
                onPressed: () {
                  Navigator.pushReplacementNamed(context, AppRoutes.login);
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}