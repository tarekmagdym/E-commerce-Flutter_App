import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../app/routes.dart';
import '../home/widgets/category_section.dart';
import 'categories_controller.dart';
import '../../../services/cart_service.dart';
import '../products/product_details_screen.dart';

/// Browse the full catalog, filtered by category chip and/or search text.
///
/// [initialCategoryId] lets other screens (e.g. Home's "See All") deep-link
/// straight into a category; defaults to the "All" chip.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key, this.initialCategoryId});

  final String? initialCategoryId;

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  final _controller = CategoriesController();
  final _cartService = CartService();

  List<CategoryModel> _categories = [];
  List<ProductModel> _allProducts = [];
  late String _selectedCategoryId;
  String _searchQuery = '';

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.initialCategoryId ?? 'all';
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await Future.wait([
        _controller.loadCategories(),
        _controller.loadProducts(),
      ]);

      if (!mounted) return;
      setState(() {
        _categories = results[0] as List<CategoryModel>;
        _allProducts = results[1] as List<ProductModel>;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  List<ProductModel> get _visibleProducts {
    final byCategory = _selectedCategoryId == 'all'
        ? _allProducts
        : _allProducts.where((p) => p.categoryId == _selectedCategoryId).toList();

    if (_searchQuery.trim().isEmpty) return byCategory;

    final query = _searchQuery.trim().toLowerCase();
    return byCategory.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  String get _selectedCategoryName {
    final match = _categories.where((c) => c.id == _selectedCategoryId);
    return match.isEmpty ? AppStrings.categoriesTitle : match.first.name;
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case 1:
        break; // already on Categories
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.cart);
        break;
      case 3:
        Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.categoriesTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        cartItemCount: _cartService.itemCount,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();
    if (_hasError) {
      return AppErrorWidget(onRetry: _loadData);
    }

    final products = _visibleProducts;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          CustomTextField(
            hintText: AppStrings.categoriesSearchHint,
            prefixIcon: Icons.search_rounded,
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 20),
          CategorySection(
            categories: _categories,
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategoryName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${products.length} ${AppStrings.productsCountSuffix}',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (products.isEmpty)
            _buildEmptyState()
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72,
              ),
              itemBuilder: (context, index) {
                final product = products[index];
                return ProductCard(
                  product: product,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                  ),
                  onAddToCart: () async {
                    await _cartService.addItem(product);
                    if (!mounted) return;
                    setState(() {});
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${product.name} — ${AppStrings.addedToCart}')),
                    );
                  },
                );
              },
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.textSecondary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            AppStrings.noProductsTitle,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            AppStrings.noProductsSubtitle,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
