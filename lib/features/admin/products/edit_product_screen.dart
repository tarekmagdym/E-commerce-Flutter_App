import 'package:flutter/material.dart';
import '../../../models/product_model.dart';
import 'add_product_screen.dart';

/// Thin wrapper around the shared ProductFormScreen defined in
/// add_product_screen.dart, kept as its own file to match the
/// project's admin folder structure.
class EditProductScreen extends StatelessWidget {
  const EditProductScreen({super.key, required this.product});

  final ProductModel product;

  @override
  Widget build(BuildContext context) => ProductFormScreen(product: product);
}