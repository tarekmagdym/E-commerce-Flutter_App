import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';
import 'product_details_screen.dart';

/// Pushed (non-tab) screen showing products for a single category —
/// reached from Home's "See All". The Categories screen still owns
/// the chip-filtered, bottom-nav "browse everything" experience;
/// this is a focused drill-down for one category with its own back
/// button, matching the original UI reference's "Products Screen".
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, required this.categoryId});

  final String categoryId;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _productService = ProductService();
  final _categoryService = CategoryService();
  final _cartService = CartService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _isSearching = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await Future.wait([
        _productService.getProductsByCategory(widget.categoryId),
        _categoryService.getCategories(),
      ]);

      if (!mounted) return;
      setState(() {
        _products = results[0] as List<ProductModel>;
        _categories = results[1] as List<CategoryModel>;
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

  String get _title {
    if (widget.categoryId == 'all') return AppStrings.allProductsTitle;
    final match = _categories.where((c) => c.id == widget.categoryId);
    return match.isEmpty ? AppStrings.allProductsTitle : match.first.name;
  }

  List<ProductModel> get _visibleProducts {
    if (_searchQuery.trim().isEmpty) return _products;
    final query = _searchQuery.trim().toLowerCase();
    return _products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close_rounded : Icons.search_rounded),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) _searchQuery = '';
              });
            },
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();
    if (_hasError) return AppErrorWidget(onRetry: _loadData);

    final products = _visibleProducts;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          if (_isSearching) ...[
            CustomTextField(
              hintText: AppStrings.categoriesSearchHint,
              prefixIcon: Icons.search_rounded,
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            const SizedBox(height: 16),
          ],
          Text(
            '${products.length} ${AppStrings.productsCountSuffix}',
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
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