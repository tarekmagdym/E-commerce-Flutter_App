enum OrderStatus { processing, shipped, delivered, cancelled }

class OrderModel {
  const OrderModel({
    required this.id,
    required this.date,
    required this.status,
    required this.total,
    required this.itemCount,
    String? orderNumber,
    this.items = const [],
    this.shippingAddress,
    this.paymentLabel,
    this.customerName = 'Ahmed Tarek',
  }) : orderNumber = orderNumber ?? id;

  /// The real Mongo `_id` — use this for API calls (GET /orders/:id,
  /// PUT /admin/orders/:id/status). Never show this in the UI.
  final String id;

  /// Human-friendly reference (e.g. "#SE-104223") — use this for
  /// display everywhere. Defaults to [id] for mock-constructed orders
  /// (Checkout/OrderService's placeOrder), where the two are the same.
  final String orderNumber;

  final DateTime date;
  final OrderStatus status;
  final double total;
  final int itemCount;
  final List<OrderItemModel> items;
  final String? shippingAddress;
  final String? paymentLabel;

  /// Single mock customer for now — there's no multi-user backend
  /// yet, so every order (seeded or placed through Checkout) belongs
  /// to the same account.
  final String customerName;

  String get formattedTotal => '\$${total.toStringAsFixed(0)}';

  String get statusLabel => labelForStatus(status);

  /// Parses an order as returned by the backend (Order.toPublicJSON(),
  /// plus the injected `customer` object on admin endpoints).
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? const [];
    return OrderModel(
      id: (json['id'] ?? '').toString(),
      orderNumber: json['orderNumber'] as String?,
      date: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      status: _statusFromString(json['status'] as String?),
      total: (json['total'] as num?)?.toDouble() ?? 0,
      itemCount: (json['itemCount'] as num?)?.toInt() ?? 0,
      items: itemsJson
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      shippingAddress: _formatShippingAddress(json['shippingAddress'] as Map<String, dynamic>?),
      paymentLabel: _formatPaymentLabel(json['paymentMethodSnapshot'] as Map<String, dynamic>?),
      customerName: (json['customer'] as Map<String, dynamic>?)?['fullName'] as String? ?? 'Customer',
    );
  }

  static OrderStatus _statusFromString(String? value) {
    switch (value) {
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      case 'processing':
      default:
        return OrderStatus.processing;
    }
  }

  static String? _formatShippingAddress(Map<String, dynamic>? addr) {
    if (addr == null) return null;
    final state = addr['state'] as String?;
    final parts = [
      addr['street'] as String?,
      addr['city'] as String?,
      if (state != null && state.isNotEmpty) state,
      addr['country'] as String?,
    ].whereType<String>().where((p) => p.isNotEmpty).join(', ');
    return parts.isEmpty ? null : parts;
  }

  static String? _formatPaymentLabel(Map<String, dynamic>? snapshot) {
    if (snapshot == null) return null;
    final brand = snapshot['brand'] as String?;
    final last4 = snapshot['last4'] as String?;
    final hasLast4 = last4 != null && last4.isNotEmpty;

    if (brand == null || brand == 'other') {
      return hasLast4 ? '•••• $last4' : null;
    }
    final label = brand[0].toUpperCase() + brand.substring(1);
    return hasLast4 ? '$label •••• $last4' : label;
  }

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

/// One line item within an order snapshot — a copy of the product's
/// name/image/price/quantity at the time of purchase, per the
/// backend's Order.items schema. Deliberately not a [CartItemModel]/
/// [ProductModel]: a placed order's items are a frozen snapshot, not
/// a live product reference, and carry no category/stock/rating.
class OrderItemModel {
  const OrderItemModel({
    required this.name,
    required this.price,
    required this.quantity,
    this.image,
  });

  final String name;
  final double price;
  final int quantity;
  final String? image;

  String get formattedPrice => '\$${price.toStringAsFixed(0)}';

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      name: json['name'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      image: json['image'] as String?,
    );
  }
}