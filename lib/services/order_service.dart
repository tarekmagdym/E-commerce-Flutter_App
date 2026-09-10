
import '../models/order_model.dart';

/// Mock order history. Swap the body of [getOrders] for a real API
/// call later — callers already treat this as async.
class OrderService {
  Future<List<OrderModel>> getOrders() async {
    // Real call will be: GET /orders
    await Future.delayed(const Duration(milliseconds: 500));
    return [
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
  }
}
