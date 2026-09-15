import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/product_model.dart';

class ProductService {
  ProductService({ApiClient? apiClient}) : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  /// In-memory wishlist state. The backend has a real /api/wishlist,
  /// but wiring it wasn't part of this pass (Cart & Checkout) — kept
  /// local so Favorites/Product Details keep working meanwhile.
  static final Set<String> _wishlistIds = {};

  Future<List<ProductModel>> getAllProducts() async {
    // limit raised since there's no pagination UI yet — revisit if
    // the catalog grows past ~100 items.
    final response = await _apiClient.get('${ApiEndpoints.products}?limit=100');
    if (!response.success) throw Exception(response.message);
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProductModel>> getProductsByCategory(String? categoryId) async {
    final query = (categoryId == null || categoryId == 'all')
        ? '?limit=100'
        : '?category=$categoryId&limit=100';
    final response = await _apiClient.get('${ApiEndpoints.products}$query');
    if (!response.success) throw Exception(response.message);
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<ProductModel>> getBestSellers() async {
    final response = await _apiClient.get(ApiEndpoints.bestSellers);
    if (!response.success) throw Exception(response.message);
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ProductModel> getProductById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.products}/$id');
    if (!response.success) throw Exception(response.message);
    return ProductModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  /// Admin create — sent as multipart with no image files. Image
  /// picking/upload isn't wired yet; the controller already handles
  /// req.files being empty.
  Future<ProductModel> addProduct({
    required String name,
    required double price,
    required String categoryId,
    required IconData icon,
    int stock = 0,
    String description = '',
  }) async {
    final response = await _apiClient.multipart(
      'POST',
      ApiEndpoints.products,
      fields: {
        'name': name,
        'price': '$price',
        'category': categoryId,
        'stock': '$stock',
        'description': description,
      },
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
    return ProductModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required String categoryId,
    required IconData icon,
    int stock = 0,
    String description = '',
  }) async {
    final response = await _apiClient.multipart(
      'PUT',
      '${ApiEndpoints.products}/$id',
      fields: {
        'name': name,
        'price': '$price',
        'category': categoryId,
        'stock': '$stock',
        'description': description,
      },
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
  }

  Future<void> deleteProduct(String id) async {
    final response = await _apiClient.delete('${ApiEndpoints.products}/$id', requiresAuth: true);
    if (!response.success) throw Exception(response.message);
  }

  bool isInWishlist(String productId) => _wishlistIds.contains(productId);

  Future<List<ProductModel>> getWishlist() async {
    final all = await getAllProducts();
    return all.where((p) => _wishlistIds.contains(p.id)).toList();
  }

  Future<void> toggleWishlist(String productId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (_wishlistIds.contains(productId)) {
      _wishlistIds.remove(productId);
    } else {
      _wishlistIds.add(productId);
    }
  }
}