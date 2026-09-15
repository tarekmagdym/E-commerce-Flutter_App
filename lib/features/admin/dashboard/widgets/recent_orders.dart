import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../models/order_model.dart';

class RecentOrders extends StatelessWidget {
  const RecentOrders({super.key, required this.orders, this.onViewAll});

  final List<OrderModel> orders;
  final VoidCallback? onViewAll;

  Color _statusColor(OrderStatus status) {
    switch (status) {
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

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  AppStrings.recentOrdersTitle,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    AppStrings.viewAllLabel,
                    style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          for (final order in orders) _RecentOrderTile(order: order, color: _statusColor(order.status)),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _RecentOrderTile extends StatelessWidget {
  const _RecentOrderTile({required this.order, required this.color});

  final OrderModel order;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              order.orderNumber,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
          Text(
            order.formattedTotal,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
            child: Text(
              order.statusLabel,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: color),
            ),
          ),
        ],
      ),
    );
  }
}