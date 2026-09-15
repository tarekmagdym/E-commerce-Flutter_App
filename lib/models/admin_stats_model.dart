class AdminStatsModel {
  const AdminStatsModel({
    required this.totalProducts,
    required this.totalOrders,
    required this.totalUsers,
    required this.totalRevenue,
  });

  final int totalProducts;
  final int totalOrders;
  final int totalUsers;
  final double totalRevenue;

  String get formattedRevenue => '\$${totalRevenue.toStringAsFixed(0)}';
}