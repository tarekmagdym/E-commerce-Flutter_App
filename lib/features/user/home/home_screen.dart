import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../app/routes.dart';
import 'home_controller.dart';
import 'widgets/category_section.dart';
import 'widgets/featured_products.dart';
import 'widgets/home_banner.dart';
import '../../../services/cart_service.dart';
import '../products/products_screen.dart';
import '../products/product_details_screen.dart';

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
  String _selectedCategoryId = 'all';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    final results = await Future.wait([
      _controller.loadCategories(),
      _controller.loadBestSellers(),
    ]);

    if (!mounted) return;
    setState(() {
      _categories = results[0] as List<CategoryModel>;
      _bestSellers = results[1] as List<ProductModel>;
      _isLoading = false;
    });
  }

  List<ProductModel> get _visibleProducts {
    if (_selectedCategoryId == 'all') return _bestSellers;
    return _bestSellers.where((p) => p.categoryId == _selectedCategoryId).toList();
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        return; // already on Home
      case 1:
        Navigator.of(context).pushNamed(AppRoutes.categories);
        break;
      case 2:
        Navigator.of(context).pushReplacementNamed(AppRoutes.cart);
        break;
      case 3:
        Navigator.of(context).pushNamed(AppRoutes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
            : RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _loadHomeData,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.homeGreeting,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          AppStrings.homeSubtitle,
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(
                        Icons.notifications_none_rounded,
                        color: AppColors.textPrimary,
                      ),
                      onPressed: () => _showComingSoon('Notifications'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              CustomTextField(
                hintText: AppStrings.searchHint,
                prefixIcon: Icons.search_rounded,
                onChanged: (_) {},
              ),

              const SizedBox(height: 20),

              HomeBanner(onShopNow: () => _showComingSoon('Shop Now')),

              const SizedBox(height: 24),

              CategorySection(
                categories: _categories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
              ),

              const SizedBox(height: 24),

              FeaturedProducts(
                products: _visibleProducts,
                onSeeAll: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductsScreen(categoryId: _selectedCategoryId),
                  ),
                ),
                onProductTap: (product) => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => ProductDetailsScreen(product: product)),
                ),
                onAddToCart: (product) async {
                  await _cartService.addItem(product);
                  if (!mounted) return;
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} — ${AppStrings.addedToCart}')),
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        cartItemCount: _cartService.itemCount,
        onTap: _handleBottomNavTap,
      ),
    );
  }
}