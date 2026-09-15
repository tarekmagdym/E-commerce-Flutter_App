import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/address_model.dart';
import '../../../services/address_service.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = AddressService();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final _state = TextEditingController();
  final _country = TextEditingController();
  final _postalCode = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    for (final c in [_fullName, _phone, _street, _city, _state, _country, _postalCode]) {
      c.dispose();
    }
    super.dispose();
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'Required' : null;

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final saved = await _service.addAddress(AddressModel(
        id: '',
        fullName: _fullName.text.trim(),
        phone: _phone.text.trim(),
        street: _street.text.trim(),
        city: _city.text.trim(),
        state: _state.text.trim(),
        country: _country.text.trim(),
        postalCode: _postalCode.text.trim(),
      ));
      if (!mounted) return;
      Navigator.of(context).pop(saved);
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
      appBar: AppBar(title: const Text('Add Address', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CustomTextField(controller: _fullName, hintText: 'Full name', prefixIcon: Icons.person_outline, validator: _required),
              const SizedBox(height: 16),
              CustomTextField(controller: _phone, hintText: 'Phone', prefixIcon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: _required),
              const SizedBox(height: 16),
              CustomTextField(controller: _street, hintText: 'Street address', prefixIcon: Icons.location_on_outlined, validator: _required),
              const SizedBox(height: 16),
              CustomTextField(controller: _city, hintText: 'City', prefixIcon: Icons.location_city_outlined, validator: _required),
              const SizedBox(height: 16),
              CustomTextField(controller: _state, hintText: 'State (optional)', prefixIcon: Icons.map_outlined),
              const SizedBox(height: 16),
              CustomTextField(controller: _country, hintText: 'Country', prefixIcon: Icons.public_outlined, validator: _required),
              const SizedBox(height: 16),
              CustomTextField(controller: _postalCode, hintText: 'Postal code (optional)', prefixIcon: Icons.markunread_mailbox_outlined),
              const SizedBox(height: 24),
              CustomButton(label: 'Save Address', isLoading: _isSaving, onPressed: _handleSave),
            ],
          ),
        ),
      ),
    );
  }
}