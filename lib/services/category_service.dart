import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/category_model.dart';

/// Wired to the real backend. NOTE: the exact /api/categories
/// request/response shape was inferred from this backend's very
/// consistent {success, data} pattern (seen firsthand across auth,
/// cart, orders, payment-methods, products) — categoryController.js
/// itself wasn't available when this was written. If anything here
/// doesn't match, the fix is isolated to this file.
class CategoryService {
  CategoryService({ApiClient? apiClient}) : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  static const _allCategory = CategoryModel(id: 'all', name: 'All', icon: Icons.apps_rounded);

  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.get(ApiEndpoints.categories);
    if (!response.success) throw Exception(response.message);
    final list = response.data as List<dynamic>? ?? [];
    final categories = list.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList();
    return [_allCategory, ...categories];
  }

  /// Excludes the 'all' pseudo-category, which is a UI filter option
  /// rather than a real, admin-manageable category.
  Future<List<CategoryModel>> getManagedCategories() async {
    final all = await getCategories();
    return all.where((c) => c.id != 'all').toList();
  }

  Future<CategoryModel> addCategory({required String name, required IconData icon}) async {
    final response = await _apiClient.post(
      ApiEndpoints.categories,
      body: {'name': name},
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
    return CategoryModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  Future<void> updateCategory({
    required String id,
    required String name,
    required IconData icon,
  }) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.categories}/$id',
      body: {'name': name},
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
  }

  Future<void> deleteCategory(String id) async {
    final response = await _apiClient.delete('${ApiEndpoints.categories}/$id', requiresAuth: true);
    if (!response.success) throw Exception(response.message);
  }
}