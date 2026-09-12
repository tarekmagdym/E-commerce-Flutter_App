import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/routes.dart';
import '../../providers/auth_provider.dart';

/// Step 2 of password reset: verifies the OTP the user got by email
/// (POST /api/auth/verify-reset-code). [email] is passed in from
/// ForgotPasswordScreen via AppRoutes.verifyResetCode's arguments.
class VerifyResetCodeScreen extends StatefulWidget {
  const VerifyResetCodeScreen({super.key, required this.email});

  final String email;

  @override
  State<VerifyResetCodeScreen> createState() => _VerifyResetCodeScreenState();
}

class _VerifyResetCodeScreenState extends State<VerifyResetCodeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final success = await auth.verifyResetCode(
      email: widget.email,
      code: _codeController.text.trim(),
    );
    if (!mounted) return;
    if (success && auth.resetToken != null) {
      Navigator.of(context).pushNamed(
        AppRoutes.resetPassword,
        arguments: {'email': widget.email, 'resetToken': auth.resetToken},
      );
    } else if (auth.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.errorMessage!)));
    }
  }

  Future<void> _resendCode() async {
    final auth = context.read<AuthProvider>();
    final success = await auth.forgotPassword(email: widget.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? 'A new code has been sent'
          : (auth.errorMessage ?? 'Failed to resend code')),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Verify Code')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Enter the code we sent to ${widget.email}'),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Verification Code'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Code is required' : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: auth.isLoading ? null : _submit,
                  child: auth.isLoading
                      ? const SizedBox(
                          height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Verify'),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: auth.isLoading ? null : _resendCode,
                  child: const Text("Didn't get a code? Resend"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
