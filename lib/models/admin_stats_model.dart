class AdminStatsModel {
  const AdminStatsModel({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalUsers,
    required this.totalRevenue,
    this.productsChangePercent = 0,
    this.ordersChangePercent = 0,
    this.usersChangePercent = 0,
    this.revenueChangePercent = 0,
  });

  final int totalProducts;
  final int totalOrders;
  final int totalUsers;
  final double totalRevenue;

  /// Month-over-month % change for each metric, from the backend's
  /// GET /admin/dashboard/stats — positive = up, negative = down.
  final double productsChangePercent;
  final double ordersChangePercent;
  final double usersChangePercent;
  final double revenueChangePercent;

  String get formattedRevenue => '\$${totalRevenue.toStringAsFixed(0)}';

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) {
    int valueOf(String key) => ((json[key] as Map<String, dynamic>?)?['value'] as num?)?.toInt() ?? 0;
    double changeOf(String key) =>
        ((json[key] as Map<String, dynamic>?)?['changePercent'] as num?)?.toDouble() ?? 0;

    return AdminStatsModel(
      totalProducts: valueOf('products'),
      totalOrders: valueOf('orders'),
      totalUsers: valueOf('users'),
      totalRevenue: ((json['revenue'] as Map<String, dynamic>?)?['value'] as num?)?.toDouble() ?? 0,
      productsChangePercent: changeOf('products'),
      ordersChangePercent: changeOf('orders'),
      usersChangePercent: changeOf('users'),
      revenueChangePercent: changeOf('revenue'),
    );
  }
}

/// One point on the dashboard's sales chart, from GET
/// /admin/dashboard/sales-chart?range=week|month|year.
class SalesPoint {
  const SalesPoint({required this.label, required this.revenue, required this.orders});

  /// 'YYYY-MM-DD' for week/month ranges, 'YYYY-MM' for year.
  final String label;
  final double revenue;
  final int orders;

  factory SalesPoint.fromJson(Map<String, dynamic> json) {
    return SalesPoint(
      label: json['label'] as String? ?? '',
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
      orders: (json['orders'] as num?)?.toInt() ?? 0,
    );
  }
}