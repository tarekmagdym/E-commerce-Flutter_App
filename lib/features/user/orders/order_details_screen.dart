import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/cart_model.dart';
import '../../../models/order_model.dart';

class OrderDetailsScreen extends StatelessWidget {
  const OrderDetailsScreen({super.key, required this.order});

  final OrderModel order;

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '${AppStrings.orderIdPrefix} ${order.id}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildStatusCard(),
            const SizedBox(height: 24),
            if (order.status != OrderStatus.cancelled) ...[
              _sectionTitle(AppStrings.orderStatusLabel),
              const SizedBox(height: 14),
              _buildStatusTimeline(),
              const SizedBox(height: 24),
            ],
            _sectionTitle(AppStrings.itemsLabel),
            const SizedBox(height: 10),
            _buildItemsSection(),
            const SizedBox(height: 24),
            if (order.shippingAddress != null) ...[
              _sectionTitle(AppStrings.shippingAddress),
              const SizedBox(height: 10),
              _buildInfoCard(Icons.location_on_outlined, order.shippingAddress!),
              const SizedBox(height: 24),
            ],
            if (order.paymentLabel != null) ...[
              _sectionTitle(AppStrings.paymentMethod),
              const SizedBox(height: 10),
              _buildInfoCard(Icons.payments_outlined, order.paymentLabel!),
              const SizedBox(height: 24),
            ],
            _sectionTitle(AppStrings.orderSummary),
            const SizedBox(height: 10),
            _buildTotalCard(),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
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
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.shopping_bag_outlined, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${AppStrings.orderIdPrefix} ${order.id}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(order.date),
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              order.statusLabel,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTimeline() {
    final steps = <_TimelineStep>[
      _TimelineStep(OrderStatus.processing, Icons.receipt_long_outlined, 'Processing'),
      _TimelineStep(OrderStatus.shipped, Icons.local_shipping_outlined, 'Shipped'),
      _TimelineStep(OrderStatus.delivered, Icons.check_circle_outline_rounded, 'Delivered'),
    ];
    final currentIndex = steps.indexWhere((s) => s.status == order.status);

    return Row(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          if (i > 0)
            Expanded(
              child: Container(
                height: 2,
                color: i <= currentIndex ? AppColors.primary : AppColors.border,
              ),
            ),
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: i <= currentIndex ? AppColors.primary : AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: i <= currentIndex ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Icon(
                  steps[i].icon,
                  size: 18,
                  color: i <= currentIndex ? Colors.white : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                steps[i].label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: i <= currentIndex ? AppColors.textPrimary : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildItemsSection() {
    if (order.items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          '${order.itemCount} ${AppStrings.productsCountSuffix}',
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: [
        for (final item in order.items) ...[
          _buildItemRow(item),
          if (item != order.items.last) const SizedBox(height: 10),
        ],
      ],
    );
  }

  Widget _buildItemRow(CartItemModel item) {
    final product = item.product;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: product.iconBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(product.icon, size: 22, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Qty ${item.quantity}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          Text(
            product.formattedPrice,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            AppStrings.totalLabel,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          Text(
            order.formattedTotal,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep {
  const _TimelineStep(this.status, this.icon, this.label);
  final OrderStatus status;
  final IconData icon;
  final String label;
}