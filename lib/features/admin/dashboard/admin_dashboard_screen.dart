import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/admin_bottom_nav.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/admin_stats_model.dart';
import '../../../models/order_model.dart';
import '../../../services/admin_service.dart';
import 'widgets/recent_orders.dart';
import 'widgets/sales_chart.dart';
import 'widgets/statistic_card.dart';
import '../../../app/routes.dart';
import '../orders/admin_orders_screen.dart';
import '../profile/admin_profile_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _service = AdminService();

  AdminStatsModel? _stats;
  List<double> _weeklySales = [];
  List<OrderModel> _recentOrders = [];

  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final results = await Future.wait([
        _service.getDashboardStats(),
        _service.getWeeklySales(),
        _service.getRecentOrders(),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = results[0] as AdminStatsModel;
        _weeklySales = results[1] as List<double>;
        _recentOrders = results[2] as List<OrderModel>;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$feature — coming soon')),
    );
  }

  void _handleBottomNavTap(int index) {
    if (index == 0) return; // already on Dashboard
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.adminProducts);
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.adminOrders);
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.adminUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.adminDashboardTitle, style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
            ),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: AdminBottomNav(currentIndex: 0, onTap: _handleBottomNavTap),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();
    if (_hasError || _stats == null) return AppErrorWidget(onRetry: _loadData);

    final stats = _stats!;

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 1.5,
            children: [
              StatisticCard(
                icon: Icons.inventory_2_outlined,
                iconBackground: AppColors.primary,
                value: '${stats.totalProducts}',
                label: AppStrings.totalProductsLabel,
              ),
              StatisticCard(
                icon: Icons.shopping_cart_outlined,
                iconBackground: AppColors.info,
                value: '${stats.totalOrders}',
                label: AppStrings.totalOrdersLabel,
              ),
              StatisticCard(
                icon: Icons.people_outline_rounded,
                iconBackground: AppColors.warning,
                value: '${stats.totalUsers}',
                label: AppStrings.totalUsersLabel,
              ),
              StatisticCard(
                icon: Icons.attach_money_rounded,
                iconBackground: AppColors.success,
                value: stats.formattedRevenue,
                label: AppStrings.totalRevenueLabel,
              ),
            ],
          ),
          const SizedBox(height: 20),
          SalesChart(values: _weeklySales),
          const SizedBox(height: 20),
          RecentOrders(
            orders: _recentOrders,
            onViewAll: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
            ),
          ),
        ],
      ),
    );
  }
}