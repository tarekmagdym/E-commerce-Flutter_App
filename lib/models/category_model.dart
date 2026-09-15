import 'package:flutter/material.dart';
import '../core/utils/category_icon_helper.dart';

class CategoryModel {
  const CategoryModel({required this.id, required this.name, required this.icon});

  final String id;
  final String name;
  final IconData icon;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String? ?? '';
    return CategoryModel(
      id: (json['id'] ?? '').toString(),
      name: name,
      icon: iconForCategoryName(name),
    );
  }
}