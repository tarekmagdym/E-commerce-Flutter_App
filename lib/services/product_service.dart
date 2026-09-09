import 'package:flutter/material.dart';
import '../models/product_model.dart';

/// Mock product data. Swap the body of each method for a real API
/// call later — callers already treat these as async.
class ProductService {
  Future<List<ProductModel>> getBestSellers() async {
    // Real call will be: GET /products?sort=best-sellers
    await Future.delayed(const Duration(milliseconds: 500));
    return const [
      ProductModel(
        id: 'p1',
        name: 'Nike Air Max',
        price: 2500,
        categoryId: 'shoes',
        icon: Icons.directions_walk_rounded,
        iconBackground: Color(0xFFEFF1F5),
        rating: 4.5,
        reviewCount: 120,
        description:
        'The Nike Air Max combines style and comfort with its iconic design and advanced cushioning technology.',
      ),
      ProductModel(
        id: 'p2',
        name: 'Classic T-Shirt',
        price: 700,
        categoryId: 'clothes',
        icon: Icons.checkroom_rounded,
        iconBackground: Color(0xFFEFF1F5),
        rating: 4.2,
        reviewCount: 64,
      ),
      ProductModel(
        id: 'p3',
        name: 'Wireless Headphones',
        price: 1800,
        categoryId: 'electronics',
        icon: Icons.headphones_rounded,
        iconBackground: Color(0xFFEFF1F5),
        rating: 4.6,
        reviewCount: 98,
      ),
      ProductModel(
        id: 'p4',
        name: 'Smart Watch',
        price: 2300,
        categoryId: 'accessories',
        icon: Icons.watch_rounded,
        iconBackground: Color(0xFFEFF1F5),
        rating: 4.3,
        reviewCount: 51,
      ),
    ];
  }
}