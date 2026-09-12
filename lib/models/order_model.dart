import 'cart_model.dart';

enum OrderStatus { processing, shipped, delivered, cancelled }

class OrderModel {
  const OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.itemCount,
    this.items = const [],
    this.shippingAddress,
    this.paymentLabel,
  });

  final String id;
  final DateTime date;
  final OrderStatus status;
  final double total;
  final int itemCount;

  /// Populated for orders placed through Checkout. Empty for the
  /// seeded mock order history, which predates per-item tracking.
  final List<CartItemModel> items;
  final String? shippingAddress;
  final String? paymentLabel;

  String get formattedTotal => '\$${total.toStringAsFixed(0)}';

  String get statusLabel {
    switch (status) {
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}
