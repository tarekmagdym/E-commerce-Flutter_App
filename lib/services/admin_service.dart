import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/admin_stats_model.dart';
import '../models/order_model.dart';

/// Talks to the /admin/* endpoints (adminRoutes.js): dashboard stats
/// plus admin order management. All require an authenticated admin
/// account — see the backend's protect + adminOnly middleware.
class AdminService {
  AdminService({ApiClient? apiClient}) : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  Future<AdminStatsModel> getDashboardStats() async {
    final response = await _apiClient.get(ApiEndpoints.adminDashboardStats, requiresAuth: true);
    if (!response.success) {
      throw Exception(response.message);
    }
    return AdminStatsModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  /// [range] is 'week', 'month', or 'year' — matches the backend's
  /// GET /admin/dashboard/sales-chart?range= query param.
  Future<List<SalesPoint>> getSalesChart({String range = 'week'}) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.adminDashboardSalesChart}?range=$range',
      requiresAuth: true,
    );
    if (!response.success) {
      throw Exception(response.message);
    }
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => SalesPoint.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Most recent orders for the dashboard's activity feed.
  Future<List<OrderModel>> getRecentOrders({int limit = 5}) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.adminDashboardRecentOrders}?limit=$limit',
      requiresAuth: true,
    );
    if (!response.success) {
      throw Exception(response.message);
    }
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// All orders (not just this dashboard's recent-5 feed), for the
  /// Admin Orders screen. [status] filters server-side when given;
  /// [limit] uses the backend's max page size since the current
  /// screen shows everything at once rather than paginating.
  Future<List<OrderModel>> adminListOrders({String? status, int limit = 100}) async {
    final query = StringBuffer('?limit=$limit');
    if (status != null) query.write('&status=$status');
    final response = await _apiClient.get(
      '${ApiEndpoints.adminOrders}$query',
      requiresAuth: true,
    );
    if (!response.success) {
      throw Exception(response.message);
    }
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> adminGetOrder(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.adminOrders}/$id', requiresAuth: true);
    if (!response.success) {
      throw Exception(response.message);
    }
    return OrderModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  Future<OrderModel> adminUpdateOrderStatus(String id, OrderStatus status) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.adminOrders}/$id/status',
      body: {'status': _statusToString(status)},
      requiresAuth: true,
    );
    if (!response.success) {
      throw Exception(response.message);
    }
    return OrderModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  static String _statusToString(OrderStatus status) {
    switch (status) {
      case OrderStatus.processing:
        return 'processing';
      case OrderStatus.shipped:
        return 'shipped';
      case OrderStatus.delivered:
        return 'delivered';
      case OrderStatus.cancelled:
        return 'cancelled';
    }
  }
}