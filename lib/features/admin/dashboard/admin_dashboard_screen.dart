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
  List<SalesPoint> _salesPoints = [];
  List<OrderModel> _recentOrders = [];
  String _range = 'week';
  bool _isChartLoading = false;

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
        _service.getSalesChart(range: _range),
        _service.getRecentOrders(),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = results[0] as AdminStatsModel;
        _salesPoints = results[1] as List<SalesPoint>;
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

  Future<void> _onRangeChanged(String range) async {
    if (range == _range) return;
    setState(() {
      _range = range;
      _isChartLoading = true;
    });

    try {
      final points = await _service.getSalesChart(range: range);
      if (!mounted) return;
      setState(() {
        _salesPoints = points;
        _isChartLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isChartLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load that range. Try again.')),
      );
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
          // FIX: replaced GridView.count(childAspectRatio: ...) with
          // IntrinsicHeight rows. A fixed aspect ratio hardcoded a cell
          // height that didn't fit the card's real content, causing the
          // "BOTTOM OVERFLOWED" errors and clipped labels. Rows sized to
          // their own content can never overflow, at any text scale —
          // same 2x2 layout, same 14px gaps, same card visuals.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatisticCard(
                    icon: Icons.inventory_2_outlined,
                    iconBackground: AppColors.primary,
                    value: '${stats.totalProducts}',
                    label: AppStrings.totalProductsLabel,
                    changePercent: stats.productsChangePercent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: StatisticCard(
                    icon: Icons.shopping_cart_outlined,
                    iconBackground: AppColors.info,
                    value: '${stats.totalOrders}',
                    label: AppStrings.totalOrdersLabel,
                    changePercent: stats.ordersChangePercent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: StatisticCard(
                    icon: Icons.people_outline_rounded,
                    iconBackground: AppColors.warning,
                    value: '${stats.totalUsers}',
                    label: AppStrings.totalUsersLabel,
                    changePercent: stats.usersChangePercent,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: StatisticCard(
                    icon: Icons.attach_money_rounded,
                    iconBackground: AppColors.success,
                    value: stats.formattedRevenue,
                    label: AppStrings.totalRevenueLabel,
                    changePercent: stats.revenueChangePercent,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _isChartLoading ? 0.5 : 1,
            duration: const Duration(milliseconds: 150),
            child: SalesChart(
              points: _salesPoints,
              range: _range,
              onRangeChanged: _onRangeChanged,
            ),
          ),
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