import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/utils/formatters.dart';
import '../../../../models/category_model.dart';
import '../../../../models/product_model.dart';
import '../../../../services/category_service.dart';

class ProductFormData {
  final String name;
  final String description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final int stock;
  final String sku;
  final bool isBestSeller;
  final List<File> newImages;
  final List<String> removeImagePublicIds;

  const ProductFormData({
    required this.name,
    required this.description,
    required this.price,
    required this.discountPrice,
    required this.categoryId,
    required this.stock,
    required this.sku,
    required this.isBestSeller,
    required this.newImages,
    required this.removeImagePublicIds,
  });
}

/// Shared form for Add & Edit. Pass [product] to edit; omit to create.
class ProductForm extends StatefulWidget {
  final ProductModel? product;
  final Future<String?> Function(ProductFormData data) onSubmit;

  const ProductForm({super.key, this.product, required this.onSubmit});

  @override
  State<ProductForm> createState() => _ProductFormState();
}

class _ProductFormState extends State<ProductForm> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  late final _name = TextEditingController(text: widget.product?.name ?? '');
  late final _description =
      TextEditingController(text: widget.product?.description ?? '');
  late final _price = TextEditingController(
      text: widget.product == null ? '' : widget.product!.price.toString());
  late final _discount = TextEditingController(
      text: widget.product?.discountPrice?.toString() ?? '');
  late final _stock = TextEditingController(
      text: widget.product == null ? '0' : widget.product!.stock.toString());
  late final _sku = TextEditingController(text: widget.product?.sku ?? '');

  String? _categoryId;
  bool _isBestSeller = false;
  List<File> _newImages = [];
  final Set<int> _removedImageIndexes = {};

  List<CategoryModel> _categories = [];
  bool _categoriesLoading = true;
  bool _submitting = false;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.product?.categoryId;
    _isBestSeller = widget.product?.isBestSeller ?? false;
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await CategoryService().getCategories();
      setState(() {
        _categories = cats;
        _categoriesLoading = false;
        if (_categoryId != null &&
            !cats.any((c) => c.id == _categoryId) &&
            cats.isNotEmpty) {
          _categoryId = cats.first.id;
        }
      });
    } catch (e) {
      setState(() => _categoriesLoading = false);
      if (mounted) showMsg(context, e.toString(), isError: true);
    }
  }

  Future<void> _pickImages() async {
    final picked = await _picker.pickMultiImage();
    if (picked.isEmpty) return;
    final keptExisting =
        (widget.product?.images.length ?? 0) - _removedImageIndexes.length;
    final roomLeft = (5 - keptExisting - _newImages.length).clamp(0, 5);
    if (roomLeft == 0) {
      if (mounted) showMsg(context, 'Maximum 5 images', isError: true);
      return;
    }
    setState(() =>
        _newImages.addAll(picked.take(roomLeft).map((x) => File(x.path))));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoryId == null) {
      showMsg(context, 'Please choose a category', isError: true);
      return;
    }
    setState(() => _submitting = true);
    final error = await widget.onSubmit(ProductFormData(
      name: _name.text.trim(),
      description: _description.text.trim(),
      price: double.parse(_price.text),
      discountPrice:
          _discount.text.trim().isEmpty ? null : double.parse(_discount.text),
      categoryId: _categoryId!,
      stock: int.tryParse(_stock.text) ?? 0,
      sku: _sku.text.trim(),
      isBestSeller: _isBestSeller,
      newImages: _newImages,
      removeImagePublicIds: _removedImageIndexes
          .map<String>((i) => widget.product!.imagePublicIds[i] as String)
          .toList(),
    ));
    if (!mounted) return;
    setState(() => _submitting = false);
    if (error == null) {
      Navigator.pop(context, true);
    } else {
      showMsg(context, error, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Images (up to 5)',
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          SizedBox(
            height: 90,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                if (product != null)
                  for (var i = 0; i < product.images.length; i++)
                    if (!_removedImageIndexes.contains(i))
                      _thumb(
                        child: CachedNetworkImage(
                            imageUrl: product.images[i],
                            fit: BoxFit.cover),
                        onRemove: () =>
                            setState(() => _removedImageIndexes.add(i)),
                      ),
                for (final f in _newImages)
                  _thumb(
                    child: Image.file(f, fit: BoxFit.cover),
                    onRemove: () => setState(() => _newImages.remove(f)),
                  ),
                if ((product?.images.length ?? 0) -
                        _removedImageIndexes.length +
                        _newImages.length <
                    5)
                  GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      width: 90,
                      height: 90,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade400),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _name,
            decoration: const InputDecoration(
                labelText: 'Product name', border: OutlineInputBorder()),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Name is required' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Description', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _price,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Price (\$)', border: OutlineInputBorder()),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Required';
                    if (double.tryParse(v) == null) return 'Invalid number';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _discount,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Discount price (optional)',
                      border: OutlineInputBorder()),
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final d = double.tryParse(v);
                      if (d == null) return 'Invalid';
                      final p = double.tryParse(_price.text);
                      if (p != null && d >= p) return 'Must be < price';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _stock,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Stock', border: OutlineInputBorder()),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _sku,
                  decoration: const InputDecoration(
                      labelText: 'SKU (optional)',
                      border: OutlineInputBorder()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _categoriesLoading
              ? const Center(child: CircularProgressIndicator())
              : DropdownButtonFormField<String>(
                  value: _categoryId,
                  decoration: const InputDecoration(
                      labelText: 'Category', border: OutlineInputBorder()),
                  items: _categories
                      .map((c) =>
                          DropdownMenuItem(value: c.id, child: Text(c.name)))
                      .toList(),
                  onChanged: (v) => setState(() => _categoryId = v),
                  validator: (v) => v == null ? 'Choose a category' : null,
                ),
          SwitchListTile(
            title: const Text('Best seller'),
            value: _isBestSeller,
            onChanged: (v) => setState(() => _isBestSeller = v),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Icon(isEdit ? Icons.save : Icons.add),
              label: Text(isEdit ? 'Save changes' : 'Add product'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _thumb({required Widget child, required VoidCallback onRemove}) {
    return Stack(
      children: [
        Container(
          width: 90,
          height: 90,
          margin: const EdgeInsets.only(right: 8),
          clipBehavior: Clip.antiAlias,
          decoration:
              BoxDecoration(borderRadius: BorderRadius.circular(12)),
          child: child,
        ),
        Positioned(
          top: 2,
          right: 10,
          child: GestureDetector(
            onTap: onRemove,
            child: const CircleAvatar(
              radius: 11,
              backgroundColor: Colors.red,
              child: Icon(Icons.close, size: 14, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}