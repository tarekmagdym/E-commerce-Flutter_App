import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/product_card.dart';
import '../../../../models/product_model.dart';

/// Horizontal rail of products (best sellers / featured).
///
/// Takes its data from the caller — no static list inside.
class FeaturedProducts extends StatelessWidget {
  const FeaturedProducts({
    super.key,
    required this.products,
    required this.onProductTap,
    required this.onAddToCart,
    this.emptyMessage = 'No products yet',
  });

  final List<ProductModel> products;
  final ValueChanged<ProductModel> onProductTap;
  final ValueChanged<ProductModel> onAddToCart;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            emptyMessage,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return SizedBox(
      height: 245,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final product = products[index];
          return SizedBox(
            width: 160,
            child: ProductCard(
              product: product,
              onTap: () => onProductTap(product),
              onAddToCart: () => onAddToCart(product),
            ),
          );
        },
      ),
    );
  }
}