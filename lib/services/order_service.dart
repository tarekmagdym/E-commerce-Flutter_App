import '../models/order_model.dart';

/// Mock order history, plus mock order placement for Checkout.
/// The list is `static` so a newly placed order persists and shows
/// up on the Orders screen within the same app session — there's no
/// backend yet to persist it. Swap the bodies below for real API
/// calls later — callers already treat everything here as async.
class OrderService {
  static final List<OrderModel> _orders = [
    OrderModel(
      id: '#SE-1042',
      date: DateTime(2026, 9, 2),
      status: OrderStatus.delivered,
      total: 2500,
      itemCount: 1,
    ),
    OrderModel(
      id: '#SE-1039',
      date: DateTime(2026, 8, 21),
      status: OrderStatus.shipped,
      total: 1900,
      itemCount: 2,
    ),
    OrderModel(
      id: '#SE-1027',
      date: DateTime(2026, 8, 5),
      status: OrderStatus.processing,
      total: 780,
      itemCount: 1,
    ),
    OrderModel(
      id: '#SE-0998',
      date: DateTime(2026, 6, 30),
      status: OrderStatus.cancelled,
      total: 1400,
      itemCount: 3,
    ),
  ];

  Future<List<OrderModel>> getOrders() async {
    // Real call will be: GET /orders
    await Future.delayed(const Duration(milliseconds: 500));
    return List.unmodifiable(_orders);
  }

  /// Places a new order from the Checkout total and inserts it at
  /// the top of the order history.
  /// Real call will be: POST /orders { items, total, ... }
  Future<OrderModel> placeOrder({
    required double total,
    required int itemCount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));
    final order = OrderModel(
      id: '#SE-${1043 + _orders.length}',
      date: DateTime.now(),
      status: OrderStatus.processing,
      total: total,
      itemCount: itemCount,
    );
    _orders.insert(0, order);
    return order;
  }
}