import '../models/admin_stats_model.dart';
import '../models/order_model.dart';
import 'order_service.dart';
import 'product_service.dart';

/// New service (not part of the original scaffold), aggregating mock
/// data for the Admin Dashboard. Real call will eventually be a
/// single GET /admin/dashboard-stats rather than these separate
/// product/order lookups.
class AdminService {
  AdminService({
    ProductService? productService,
    OrderService? orderService,
  })  : _productService = productService ?? ProductService(),
        _orderService = orderService ?? OrderService();

  final ProductService _productService;
  final OrderService _orderService;

  /// No Users service/screen exists yet — this stays a fixed mock
  /// count until Admin Users is built.
  static const int _mockTotalUsers = 128;

  Future<AdminStatsModel> getDashboardStats() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final products = await _productService.getAllProducts();
    final orders = await _orderService.getOrders();
    final revenue = orders.fold<double>(0, (sum, order) => sum + order.total);

    return AdminStatsModel(
      totalProducts: products.length,
      totalOrders: orders.length,
      totalUsers: _mockTotalUsers,
      totalRevenue: revenue,
    );
  }

  /// Mock 7-day sales series for the dashboard chart.
  /// Real call will be: GET /admin/sales?range=7d
  Future<List<double>> getWeeklySales() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return const [1800, 2400, 2100, 3200, 2800, 3600, 3100];
  }

  /// Most recent orders for the dashboard's activity feed.
  Future<List<OrderModel>> getRecentOrders({int limit = 5}) async {
    final orders = await _orderService.getOrders();
    return orders.take(limit).toList();
  }
}