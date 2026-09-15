import 'package:flutter/material.dart';
import '../models/category_model.dart';

/// Mock category data. The list is `static` so admin-side
/// add/edit/delete actions persist within the same app session and
/// are reflected back on the customer-facing Home/Categories/Products
/// screens — there's no backend yet. Swap the bodies below for real
/// API calls later — callers already treat everything here as async.
class CategoryService {
  static final List<CategoryModel> _categories = [
    const CategoryModel(id: 'all', name: 'All', icon: Icons.apps_rounded),
    const CategoryModel(id: 'shoes', name: 'Shoes', icon: Icons.directions_walk_rounded),
    const CategoryModel(id: 'clothes', name: 'Clothes', icon: Icons.checkroom_rounded),
    const CategoryModel(id: 'electronics', name: 'Electronics', icon: Icons.headphones_rounded),
    const CategoryModel(id: 'accessories', name: 'Accessories', icon: Icons.watch_rounded),
  ];

  Future<List<CategoryModel>> getCategories() async {
    // Real call will be: GET /categories
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_categories);
  }

  /// Excludes the 'all' pseudo-category, which is a UI filter option
  /// rather than a real, admin-manageable category.
  Future<List<CategoryModel>> getManagedCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _categories.where((c) => c.id != 'all').toList();
  }

  /// Real call will be: POST /categories
  Future<CategoryModel> addCategory({required String name, required IconData icon}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final category = CategoryModel(
      id: 'cat_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
    );
    _categories.add(category);
    return category;
  }

  /// Real call will be: PUT /categories/:id
  Future<void> updateCategory({
    required String id,
    required String name,
    required IconData icon,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final index = _categories.indexWhere((c) => c.id == id);
    if (index == -1) return;
    _categories[index] = CategoryModel(id: id, name: name, icon: icon);
  }

  /// Real call will be: DELETE /categories/:id
  Future<void> deleteCategory(String id) async {
    await Future.delayed(const Duration(milliseconds: 400));
    _categories.removeWhere((c) => c.id == id);
  }
}