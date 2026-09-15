import 'package:flutter/material.dart';

/// The backend doesn't store a decorative icon for categories or
/// products — this maps a category name to a sensible icon locally,
/// purely cosmetic. Used by both CategoryModel and ProductModel.
IconData iconForCategoryName(String name) {
  final lower = name.toLowerCase();
  if (lower.contains('shoe')) return Icons.directions_walk_rounded;
  if (lower.contains('cloth') || lower.contains('fashion')) return Icons.checkroom_rounded;
  if (lower.contains('electron')) return Icons.headphones_rounded;
  if (lower.contains('accessor')) return Icons.watch_rounded;
  if (lower.contains('home') || lower.contains('kitchen') || lower.contains('furnitur')) {
    return Icons.chair_rounded;
  }
  if (lower.contains('beauty') || lower.contains('health')) return Icons.spa_rounded;
  if (lower.contains('book')) return Icons.book_rounded;
  if (lower.contains('toy')) return Icons.toys_rounded;
  if (lower.contains('sport')) return Icons.sports_basketball_rounded;
  return Icons.category_rounded;
}