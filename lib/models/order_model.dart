enum OrderStatus { processing, shipped, delivered, cancelled }

class OrderModel {
  const OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.itemCount,
  });

  final String id;
  final DateTime date;
  final OrderStatus status;
  final double total;
  final int itemCount;

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
