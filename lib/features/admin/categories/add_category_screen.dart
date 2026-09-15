import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';

const _iconOptions = <IconData>[
  Icons.apps_rounded,
  Icons.directions_walk_rounded,
  Icons.checkroom_rounded,
  Icons.headphones_rounded,
  Icons.watch_rounded,
  Icons.shopping_bag_outlined,
  Icons.sports_basketball_outlined,
  Icons.home_outlined,
  Icons.book_outlined,
  Icons.spa_outlined,
  Icons.toys_outlined,
  Icons.kitchen_outlined,
];

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({super.key, this.category});

  /// Passed when editing an existing category; null when adding new.
  final CategoryModel? category;

  @override
  State<AddCategoryScreen> createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = CategoryService();
  late final TextEditingController _nameController;

  IconData _selectedIcon = _iconOptions.first;
  bool _isSaving = false;

  bool get _isEditing => widget.category != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    if (widget.category != null) _selectedIcon = widget.category!.icon;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    if (_isEditing) {
      await _service.updateCategory(
        id: widget.category!.id,
        name: _nameController.text.trim(),
        icon: _selectedIcon,
      );
    } else {
      await _service.addCategory(name: _nameController.text.trim(), icon: _selectedIcon);
    }

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          _isEditing ? AppStrings.editCategoryTitle : AppStrings.addCategoryTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: AppStrings.categoryNameHint,
                prefixIcon: Icons.label_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a category name';
                  }
                  if (value.trim().length < 2) return 'Name is too short';
                  return null;
                },
              ),
              const SizedBox(height: 24),
              const Text(
                AppStrings.chooseIconLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _iconOptions.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  final icon = _iconOptions[index];
                  final isSelected = icon == _selectedIcon;
                  return InkWell(
                    onTap: () => setState(() => _selectedIcon = icon),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected ? Colors.white : AppColors.textSecondary,
                        size: 22,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              CustomButton(
                label: _isEditing ? AppStrings.saveChanges : AppStrings.addCategoryTitle,
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}