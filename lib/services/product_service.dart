import 'package:flutter/material.dart';
import '../models/product_model.dart';

/// Mock product data. Swap the body of each method for a real API
/// call later — callers already treat these as async.
class ProductService {
  /// Full mock catalog used by [getAllProducts] and [getProductsByCategory].
  /// Kept separate from [getBestSellers] so that screen's data stays
  /// exactly as it was.
  static final List<ProductModel> _catalog = [
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
      id: 'p5',
      name: 'Running Sneakers',
      price: 1900,
      categoryId: 'shoes',
      icon: Icons.directions_run_rounded,
      iconBackground: Color(0xFFEFF1F5),
      rating: 4.1,
      reviewCount: 44,
    ),
    ProductModel(
      id: 'p6',
      name: 'Leather Boots',
      price: 3200,
      categoryId: 'shoes',
      icon: Icons.hiking_rounded,
      iconBackground: Color(0xFFEFF1F5),
      rating: 4.7,
      reviewCount: 88,
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
      id: 'p7',
      name: 'Denim Jacket',
      price: 1600,
      categoryId: 'clothes',
      icon: Icons.dry_cleaning_rounded,
      iconBackground: Color(0xFFEFF1F5),
      rating: 4.4,
      reviewCount: 37,
    ),
    ProductModel(
      id: 'p8',
      name: 'Winter Hoodie',
      price: 1200,
      categoryId: 'clothes',
      icon: Icons.checkroom_rounded,
      iconBackground: Color(0xFFEFF1F5),
      rating: 4.0,
      reviewCount: 29,
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
      id: 'p9',
      name: 'Bluetooth Speaker',
      price: 1400,
      categoryId: 'electronics',
      icon: Icons.speaker_rounded,
      iconBackground: Color(0xFFEFF1F5),
      rating: 4.3,
      reviewCount: 52,
    ),
    ProductModel(
      id: 'p10',
      name: 'Smartphone Stand',
      price: 250,
      categoryId: 'electronics',
      icon: Icons.smartphone_rounded,
      iconBackground: Color(0xFFEFF1F5),
      rating: 3.9,
      reviewCount: 18,
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
    ProductModel(
      id: 'p11',
      name: 'Leather Wallet',
      price: 550,
      categoryId: 'accessories',
      icon: Icons.wallet_rounded,
      iconBackground: Color(0xFFEFF1F5),
      rating: 4.5,
      reviewCount: 40,
    ),
    ProductModel(
      id: 'p12',
      name: 'Sunglasses',
      price: 480,
      categoryId: 'accessories',
      icon: Icons.wb_sunny_rounded,
      iconBackground: Color(0xFFEFF1F5),
      rating: 4.1,
      reviewCount: 33,
    ),
  ];

  /// Full catalog for the Categories screen.
  Future<List<ProductModel>> getAllProducts() async {
    // Real call will be: GET /products
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_catalog);
  }

  /// Products for a single category. Pass `null` or `'all'` for the
  /// full catalog.
  Future<List<ProductModel>> getProductsByCategory(String? categoryId) async {
    // Real call will be: GET /products?category=$categoryId
    await Future.delayed(const Duration(milliseconds: 500));
    if (categoryId == null || categoryId == 'all') return List.unmodifiable(_catalog);
    return _catalog.where((p) => p.categoryId == categoryId).toList();
  }

  /// Real call will be: POST /products
  Future<ProductModel> addProduct({
    required String name,
    required double price,
    required String categoryId,
    required IconData icon,
    int stock = 0,
    String description = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final product = ProductModel(
      id: 'prod_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      price: price,
      categoryId: categoryId,
      icon: icon,
      iconBackground: const Color(0xFFEFF1F5),
      stock: stock,
      description: description,
    );
    _catalog.add(product);
    return product;
  }

  /// Real call will be: PUT /products/:id
  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required String categoryId,
    required IconData icon,
    int stock = 0,
    String description = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final index = _catalog.indexWhere((p) => p.id == id);
    if (index == -1) return;
    final existing = _catalog[index];
    _catalog[index] = ProductModel(
      id: id,
      name: name,
      price: price,
      categoryId: categoryId,
      icon: icon,
      iconBackground: existing.iconBackground,
      rating: existing.rating,
      reviewCount: existing.reviewCount,
      stock: stock,
      description: description,
    );
  }

  /// Real call will be: DELETE /products/:id
  Future<void> deleteProduct(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _catalog.removeWhere((p) => p.id == id);
  }

  /// In-memory wishlist state (mirrors CartService's static-list
  /// pattern) so a toggle from Product Details is reflected on the
  /// Wishlist screen and vice versa, within the same app session.
  static final Set<String> _wishlistIds = {'p1', 'p3', 'p9', 'p12'};

  /// Mock saved-for-later items for the Wishlist screen.
  Future<List<ProductModel>> getWishlist() async {
    // Real call will be: GET /users/me/wishlist
    await Future.delayed(const Duration(milliseconds: 400));
    return _catalog.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  bool isInWishlist(String productId) => _wishlistIds.contains(productId);

  /// Real call will be: POST/DELETE /users/me/wishlist/:productId
  Future<void> toggleWishlist(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
  }

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