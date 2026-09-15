import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/admin_bottom_nav.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/order_model.dart';
import '../../../services/admin_service.dart';
import 'admin_order_details_screen.dart';
import '../profile/admin_profile_screen.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final _service = AdminService();

  List<OrderModel> _orders = [];
  OrderStatus? _selectedFilter;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final orders = await _service.adminListOrders();
      if (!mounted) return;
      setState(() {
        _orders = orders;
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

  List<OrderModel> get _visibleOrders {
    if (_selectedFilter == null) return _orders;
    return _orders.where((o) => o.status == _selectedFilter).toList();
  }

  void _handleBottomNavTap(int index) {
    if (index == 2) return; // already on Orders
    if (index == 0) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.adminDashboard);
      return;
    }
    if (index == 1) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.adminProducts);
      return;
    }
    Navigator.of(context).pushReplacementNamed(AppRoutes.adminUsers);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.adminOrdersTitle, style: TextStyle(fontWeight: FontWeight.bold)),
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
      bottomNavigationBar: AdminBottomNav(currentIndex: 2, onTap: _handleBottomNavTap),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();
    if (_hasError) return AppErrorWidget(onRetry: _loadOrders);

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _loadOrders,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildFilterChips(),
          const SizedBox(height: 16),
          if (_visibleOrders.isEmpty)
            _buildEmptyState()
          else
            for (final order in _visibleOrders) ...[
              _AdminOrderTile(
                order: order,
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => AdminOrderDetailsScreen(order: order)),
                  );
                  _loadOrders();
                },
              ),
              const SizedBox(height: 12),
            ],
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = <OrderStatus?>[null, ...OrderStatus.values];

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final label = filter == null ? AppStrings.allFilterLabel : OrderModel.labelForStatus(filter);
          final isSelected = _selectedFilter == filter;

          return ChoiceChip(
            label: Text(label),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedFilter = filter),
            selectedColor: AppColors.primary,
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: isSelected ? AppColors.primary : AppColors.border),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Center(
        child: Text(AppStrings.noOrdersTitle, style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
      ),
    );
  }
}

class _AdminOrderTile extends StatelessWidget {
  const _AdminOrderTile({required this.order, required this.onTap});

  final OrderModel order;
  final VoidCallback onTap;

  Color get _statusColor {
    switch (order.status) {
      case OrderStatus.processing:
        return AppColors.warning;
      case OrderStatus.shipped:
        return AppColors.info;
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.danger;
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
              alignment: Alignment.center,
              child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${AppStrings.orderIdPrefix} ${order.orderNumber}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${order.customerName} • ${_formatDate(order.date)}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  order.formattedTotal,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 5),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: _statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    order.statusLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: _statusColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}