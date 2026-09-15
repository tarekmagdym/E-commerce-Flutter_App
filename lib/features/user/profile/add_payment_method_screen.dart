import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/payment_method_model.dart';
import '../../../services/payment_method_service.dart';

class AddPaymentMethodScreen extends StatefulWidget {
  const AddPaymentMethodScreen({super.key});

  @override
  State<AddPaymentMethodScreen> createState() => _AddPaymentMethodScreenState();
}

class _AddPaymentMethodScreenState extends State<AddPaymentMethodScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = PaymentMethodService();
  final _last4Controller = TextEditingController();
  final _expiryController = TextEditingController();
  String _brand = 'visa';
  bool _isSaving = false;

  @override
  void dispose() {
    _last4Controller.dispose();
    _expiryController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final method = await _service.addPaymentMethod(
        brand: _brand,
        last4: _last4Controller.text.trim(),
        expiry: _expiryController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(method);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add Card', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              DropdownButtonFormField<String>(
                value: _brand,
                decoration: const InputDecoration(labelText: 'Card brand'),
                items: const [
                  DropdownMenuItem(value: 'visa', child: Text('Visa')),
                  DropdownMenuItem(value: 'mastercard', child: Text('Mastercard')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _brand = value ?? 'visa'),
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _last4Controller,
                hintText: 'Last 4 digits',
                prefixIcon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
                validator: (v) => (v == null || !RegExp(r'^\d{4}$').hasMatch(v.trim()))
                    ? 'Enter exactly 4 digits'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _expiryController,
                hintText: 'Expiry (MM/YY)',
                prefixIcon: Icons.calendar_today_outlined,
                validator: (v) => (v == null || !RegExp(r'^\d{2}/\d{2}$').hasMatch(v.trim()))
                    ? 'Use MM/YY format'
                    : null,
              ),
              const SizedBox(height: 24),
              CustomButton(label: 'Save Card', isLoading: _isSaving, onPressed: _handleSave),
            ],
          ),
        ),
      ),
    );
  }
}