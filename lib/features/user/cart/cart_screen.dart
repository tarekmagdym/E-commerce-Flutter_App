import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_bottom_nav.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/cart_model.dart';
import 'cart_controller.dart';
import 'widgets/cart_item_card.dart';
import 'checkout_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _controller = CartController();

  List<CartItemModel> _items = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final items = await _controller.loadCart();
      if (!mounted) return;
      setState(() {
        _items = items;
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

  Future<void> _updateQuantity(String productId, int quantity) async {
    await _controller.updateQuantity(productId, quantity);
    await _loadCart();
  }

  Future<void> _removeItem(String productId) async {
    await _controller.removeItem(productId);
    await _loadCart();
  }

  Future<void> _clearCart() async {
    await _controller.clearCart();
    await _loadCart();
  }

  void _handleBottomNavTap(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed(AppRoutes.home);
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed(AppRoutes.categories);
        break;
      case 2:
        break; // already on Cart
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
          AppStrings.cartTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (_items.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _clearCart,
            ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!_isLoading && !_hasError && _items.isNotEmpty) _buildSummaryBar(),
          AppBottomNav(
            currentIndex: 2,
            cartItemCount: _controller.itemCount,
            onTap: _handleBottomNavTap,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();
    if (_hasError) return AppErrorWidget(onRetry: _loadCart);
    if (_items.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadCart,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        itemCount: _items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return CartItemCard(
            item: item,
            onIncrement: () => _updateQuantity(item.product.id, item.quantity + 1),
            onDecrement: () => _updateQuantity(item.product.id, item.quantity - 1),
            onRemove: () => _removeItem(item.product.id),
          );
        },
      ),
    );
  }

  Widget _buildSummaryBar() {
    final itemCount = _controller.itemCount;
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${AppStrings.totalLabel} ($itemCount ${AppStrings.cartItemsCountSuffix})',
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              Text(
                '\$${_controller.subtotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: AppStrings.checkout,
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CheckoutScreen()),
              );
              if (!mounted) return;
              _loadCart();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: AppColors.textSecondary,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.emptyCartTitle,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              AppStrings.emptyCartSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 20),
            CustomButton(
              label: AppStrings.browseProducts,
              onPressed: () => Navigator.of(context).pushReplacementNamed(AppRoutes.home),
            ),
          ],
        ),
      ),
    );
  }
}