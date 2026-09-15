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
    this.customerName = 'Ahmed Tarek',
  });

  final String id;
  final DateTime date;
  final OrderStatus status;
  final double total;
  final int itemCount;
  final List<CartItemModel> items;
  final String? shippingAddress;
  final String? paymentLabel;

  /// Single mock customer for now — there's no multi-user backend
  /// yet, so every order (seeded or placed through Checkout) belongs
  /// to the same account.
  final String customerName;


  String get formattedTotal => '\$${total.toStringAsFixed(0)}';

  String get statusLabel => labelForStatus(status);

  static String labelForStatus(OrderStatus status) {
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
