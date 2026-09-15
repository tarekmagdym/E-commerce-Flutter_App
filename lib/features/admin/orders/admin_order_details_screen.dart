import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../models/cart_model.dart';
import '../../../models/order_model.dart';
import '../../../services/order_service.dart';

class AdminOrderDetailsScreen extends StatefulWidget {
  const AdminOrderDetailsScreen({super.key, required this.order});

  final OrderModel order;

  @override
  State<AdminOrderDetailsScreen> createState() => _AdminOrderDetailsScreenState();
}

class _AdminOrderDetailsScreenState extends State<AdminOrderDetailsScreen> {
  final _service = OrderService();

  late OrderStatus _status;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _status = widget.order.status;
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _colorFor(OrderStatus status) {
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

  Future<void> _handleUpdateStatus(OrderStatus status) async {
    if (status == _status) return;
    setState(() => _isUpdating = true);
    await _service.updateStatus(widget.order.id, status);
    if (!mounted) return;
    setState(() {
      _status = status;
      _isUpdating = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text(AppStrings.statusUpdatedMessage)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

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
            _buildHeaderCard(order),
            const SizedBox(height: 24),
            _sectionTitle(AppStrings.updateStatusLabel),
            const SizedBox(height: 12),
            _buildStatusActions(),
            const SizedBox(height: 24),
            _sectionTitle(AppStrings.itemsLabel),
            const SizedBox(height: 10),
            _buildItemsSection(order),
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
            _buildTotalCard(order),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary));
  }

  Widget _buildHeaderCard(OrderModel order) {
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
            decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12)),
            alignment: Alignment.center,
            child: const Icon(Icons.person_outline_rounded, color: AppColors.textPrimary, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.customerName,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text(_formatDate(order.date), style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: _colorFor(_status).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(
              OrderModel.labelForStatus(_status),
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _colorFor(_status)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusActions() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final status in OrderStatus.values)
          ChoiceChip(
            label: Text(OrderModel.labelForStatus(status)),
            selected: _status == status,
            onSelected: _isUpdating ? null : (_) => _handleUpdateStatus(status),
            selectedColor: _colorFor(status),
            backgroundColor: AppColors.surface,
            labelStyle: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _status == status ? Colors.white : AppColors.textSecondary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: _status == status ? _colorFor(status) : AppColors.border),
            ),
          ),
      ],
    );
  }

  Widget _buildItemsSection(OrderModel order) {
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
            decoration: BoxDecoration(color: product.iconBackground, borderRadius: BorderRadius.circular(10)),
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
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 3),
                Text('Qty ${item.quantity}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
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
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary))),
        ],
      ),
    );
  }

  Widget _buildTotalCard(OrderModel order) {
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