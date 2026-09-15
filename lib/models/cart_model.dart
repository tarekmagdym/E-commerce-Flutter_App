class CartItemModel {
  const CartItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  final String productId;
  final String name;
  final double price;
  final int quantity;
  final String? image;

  double get lineTotal => price * quantity;

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      productId: (json['productId'] ?? '').toString(),
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image'] as String?,
    );
  }
}