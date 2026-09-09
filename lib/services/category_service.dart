import 'package:flutter/material.dart';
import '../models/category_model.dart';

/// Mock category data. Swap the body of [getCategories] for a real
/// API call later — callers already treat this as async.
class CategoryService {
  Future<List<CategoryModel>> getCategories() async {
    // Real call will be: GET /categories
    await Future.delayed(const Duration(milliseconds: 400));
    return const [
      CategoryModel(id: 'all', name: 'All', icon: Icons.apps_rounded),
      CategoryModel(id: 'shoes', name: 'Shoes', icon: Icons.directions_walk_rounded),
      CategoryModel(id: 'clothes', name: 'Clothes', icon: Icons.checkroom_rounded),
      CategoryModel(id: 'electronics', name: 'Electronics', icon: Icons.headphones_rounded),
      CategoryModel(id: 'accessories', name: 'Accessories', icon: Icons.watch_rounded),
    ];
  }
}