import 'package:flutter/material.dart';
import '../core/utils/category_icon_helper.dart';

class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.icon,
    required this.iconBackground,
    this.discountPrice,
    this.images = const [],
    this.rating = 0,
    this.reviewCount = 0,
    this.description = '',
    this.stock = 0,
  });

  final String id;
  final String name;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final IconData icon;
  final Color iconBackground;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String description;
  final int stock;

  /// Matches the backend's `effectivePrice` virtual: the discounted
  /// price if one is set, otherwise the regular price.
  double get effectivePrice => discountPrice ?? price;

  String get formattedPrice => '\$${effectivePrice.toStringAsFixed(0)}';

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final categoryName = json['categoryName'] as String? ?? '';
    return ProductModel(
      id: (json['id'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      categoryId: (json['categoryId'] ?? '').toString(),
      icon: iconForCategoryName(categoryName),
      iconBackground: const Color(0xFFEFF1F5),
      images: (json['images'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['reviewCount'] as num?)?.toInt() ?? 0,
      description: json['description'] as String? ?? '',
      stock: (json['stock'] as num?)?.toInt() ?? 0,
    );
  }

  bool? get isBestSeller => null;

  String? get sku => null;

  get imagePublicIds => null;
}