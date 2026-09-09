import 'package:flutter/material.dart';

/// No real product images/assets yet — [icon] + [iconBackground] stand
/// in for the product photo until real image URLs come from the backend.
class ProductModel {
  const ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.icon,
    required this.iconBackground,
    this.rating = 0,
    this.reviewCount = 0,
    this.description = '',
  });

  final String id;
  final String name;
  final double price;
  final String categoryId;
  final IconData icon;
  final Color iconBackground;
  final double rating;
  final int reviewCount;
  final String description;

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';
}