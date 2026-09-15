import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';

const _productIconOptions = <IconData>[
  Icons.directions_walk_rounded,
  Icons.directions_run_rounded,
  Icons.hiking_rounded,
  Icons.checkroom_rounded,
  Icons.dry_cleaning_rounded,
  Icons.headphones_rounded,
  Icons.speaker_rounded,
  Icons.smartphone_rounded,
  Icons.watch_rounded,
  Icons.wallet_rounded,
  Icons.wb_sunny_rounded,
  Icons.shopping_bag_outlined,
];

/// Shared add/edit form. [AddProductScreen] below uses it with no
/// initial product; EditProductScreen (a separate file, per the
/// project's admin folder structure) passes an existing one in —
/// this avoids duplicating the whole form between two files.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final ProductModel? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productService = ProductService();
  final _categoryService = CategoryService();

  late final TextEditingController _nameController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;

  List<CategoryModel> _categories = [];
  String? _selectedCategoryId;
  IconData _selectedIcon = _productIconOptions.first;

  bool _isLoadingCategories = true;
  bool _isSaving = false;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _nameController = TextEditingController(text: product?.name ?? '');
    _priceController = TextEditingController(
      text: product != null ? product.price.toStringAsFixed(0) : '',
    );
    _stockController = TextEditingController(text: product != null ? '${product.stock}' : '');
    _descriptionController = TextEditingController(text: product?.description ?? '');
    _selectedCategoryId = product?.categoryId;
    if (product != null) _selectedIcon = product.icon;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final categories = await _categoryService.getManagedCategories();
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _selectedCategoryId ??= categories.isNotEmpty ? categories.first.id : null;
      _isLoadingCategories = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate() || _selectedCategoryId == null) return;

    setState(() => _isSaving = true);

    final price = double.tryParse(_priceController.text.trim()) ?? 0;
    final stock = int.tryParse(_stockController.text.trim()) ?? 0;

    if (_isEditing) {
      await _productService.updateProduct(
        id: widget.product!.id,
        name: _nameController.text.trim(),
        price: price,
        categoryId: _selectedCategoryId!,
        icon: _selectedIcon,
        stock: stock,
        description: _descriptionController.text.trim(),
      );
    } else {
      await _productService.addProduct(
        name: _nameController.text.trim(),
        price: price,
        categoryId: _selectedCategoryId!,
        icon: _selectedIcon,
        stock: stock,
        description: _descriptionController.text.trim(),
      );
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
          _isEditing ? AppStrings.editProductTitle : AppStrings.addProductTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: _isLoadingCategories
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              CustomTextField(
                controller: _nameController,
                hintText: AppStrings.productNameHint,
                prefixIcon: Icons.label_outline_rounded,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      hintText: AppStrings.priceHint,
                      prefixIcon: Icons.attach_money_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        if (double.tryParse(value.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      hintText: AppStrings.stockHint,
                      prefixIcon: Icons.inventory_2_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Required';
                        if (int.tryParse(value.trim()) == null) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descriptionController,
                hintText: AppStrings.descriptionHint,
                prefixIcon: Icons.notes_rounded,
              ),
              const SizedBox(height: 24),
              const Text(
                AppStrings.chooseIconLabel,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 12),
              _buildIconGrid(),
              const SizedBox(height: 28),
              CustomButton(
                label: _isEditing ? AppStrings.saveChanges : AppStrings.addProductTitle,
                isLoading: _isSaving,
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCategoryId,
          isExpanded: true,
          hint: const Text(AppStrings.categoryLabel),
          items: _categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
          onChanged: (value) => setState(() => _selectedCategoryId = value),
        ),
      ),
    );
  }

  Widget _buildIconGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _productIconOptions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final icon = _productIconOptions[index];
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
            child: Icon(icon, color: isSelected ? Colors.white : AppColors.textSecondary, size: 22),
          ),
        );
      },
    );
  }
}

class AddProductScreen extends StatelessWidget {
  const AddProductScreen({super.key});

  @override
  Widget build(BuildContext context) => const ProductFormScreen();
}