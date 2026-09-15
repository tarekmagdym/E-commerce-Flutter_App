import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../core/widgets/product_card.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/cart_service.dart';
import '../products/product_details_screen.dart';
import 'home_controller.dart';
import 'widgets/category_section.dart';
import 'widgets/featured_products.dart';
import 'widgets/home_banner.dart';

/// Home screen. All content (categories, best sellers, catalog) comes from
/// the backend through [HomeController] — same flow as CategoriesScreen.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _controller = HomeController();
  final _cartService = CartService();

  List<CategoryModel> _categories = [];
  List<ProductModel> _bestSellers = [];
  List<ProductModel> _allProducts = [];

  String _searchQuery = '';
  bool _isLoading = true;
  bool _hasError = false;

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
      final data = await _controller.loadHomeData();
      if (!mounted) return;
      setState(() {
        _categories = data.categories;
        _bestSellers = data.bestSellers;
        _allProducts = data.allProducts;
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

  /// When the user types here we show search results instead of the
  /// normal home sections.
  List<ProductModel> get _searchResults {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return const [];
    return _allProducts
        .where((p) => p.name.toLowerCase().contains(query))
        .toList();
  }

  bool get _isSearching => _searchQuery.trim().isNotEmpty;

  Future<void> _openProduct(ProductModel product) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
    );
    if (!mounted) return;
    setState(() {}); // refresh cart badge / wishlist state
  }

  Future<void> _addToCart(ProductModel product) async {
    await _cartService.addItem(product);
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${product.name} — ${AppStrings.addedToCart}')),
    );
  }

  void _openCategory(String categoryId) {
    Navigator.of(context).pushNamed(
      AppRoutes.categories,
      arguments: {'categoryId': categoryId},
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        break; // already on Home
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.categories);
        break;
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
          'Home',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.cart),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        cartItemCount: _cartService.itemCount,
        onTap: _handleBottomNavTap,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();
    if (_hasError) return AppErrorWidget(onRetry: _loadData);

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
          if (_isSearching) ..._buildSearchResults() else ..._buildHomeSections(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  List<Widget> _buildHomeSections() {
    return [
      const HomeBanner(),
      const SizedBox(height: 24),
      if (_categories.isNotEmpty) ...[
        _buildSectionHeader(
          AppStrings.categoriesTitle,
          onSeeAll: () => Navigator.of(context).pushNamed(AppRoutes.categories),
        ),
        const SizedBox(height: 12),
        CategorySection(
          categories: _categories,
          selectedCategoryId: null,
          onCategorySelected: _openCategory,
        ),
        const SizedBox(height: 24),
      ],
      _buildSectionHeader(
        'Best Sellers',
        onSeeAll: () => Navigator.of(context).pushNamed(AppRoutes.categories),
      ),
      const SizedBox(height: 12),
      FeaturedProducts(
        products: _bestSellers,
        onProductTap: _openProduct,
        onAddToCart: _addToCart,
        emptyMessage: AppStrings.noProductsTitle,
      ),
      const SizedBox(height: 24),
      _buildSectionHeader(
        'All Products',
        trailing: '${_allProducts.length} ${AppStrings.productsCountSuffix}',
      ),
      const SizedBox(height: 12),
      if (_allProducts.isEmpty)
        _buildEmptyState()
      else
        _buildGrid(_allProducts),
    ];
  }

  List<Widget> _buildSearchResults() {
    final results = _searchResults;
    return [
      _buildSectionHeader(
        AppStrings.categoriesTitle,
        trailing: '${results.length} ${AppStrings.productsCountSuffix}',
      ),
      const SizedBox(height: 12),
      if (results.isEmpty) _buildEmptyState() else _buildGrid(results),
    ];
  }

  Widget _buildGrid(List<ProductModel> products) {
    return GridView.builder(
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
          onTap: () => _openProduct(product),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  Widget _buildSectionHeader(
    String title, {
    String? trailing,
    VoidCallback? onSeeAll,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null)
          Text(
            trailing,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          )
        else if (onSeeAll != null)
          TextButton(
            onPressed: onSeeAll,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'See All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
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