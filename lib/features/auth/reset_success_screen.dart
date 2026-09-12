import 'package:flutter/material.dart';
import '../../app/routes.dart';

/// Shown after a successful /api/auth/reset-password call.
class ResetSuccessScreen extends StatelessWidget {
  const ResetSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 24),
                Text('Password Reset!', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                const Text(
                  'Your password has been changed successfully. '
                  'You can now log in with your new password.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context)
                        .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
                    child: const Text('Back to Log In'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
