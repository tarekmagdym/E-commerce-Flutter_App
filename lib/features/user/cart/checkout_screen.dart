import 'package:flutter/material.dart';
import '../../../app/routes.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/error_widget.dart';
import '../../../core/widgets/loading_widget.dart';
import '../../../models/cart_model.dart';
import '../../../models/order_model.dart';
import '../../../models/address_model.dart';
import '../../../models/payment_method_model.dart';
import '../orders/orders_screen.dart';
import '../profile/addresses_screen.dart';
import 'checkout_controller.dart';


class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _controller = CheckoutController();

  List<CartItemModel> _items = [];
  List<PaymentMethodModel> _cards = [];
  AddressModel? _selectedAddress;
  String _selectedPaymentId = 'cod';

  bool _isLoading = true;
  bool _hasError = false;
  bool _isPlacingOrder = false;

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
        _controller.loadCartItems(),
        _controller.loadPaymentMethods(),
        _controller.loadShippingAddress(),
      ]);

      if (!mounted) return;
      setState(() {
        _items = results[0] as List<CartItemModel>;
        _cards = results[1] as List<PaymentMethodModel>;
        _selectedAddress = results[2] as AddressModel;
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

  String get _selectedPaymentLabel {
    if (_selectedPaymentId == 'cod') return AppStrings.cashOnDelivery;
    final card = _cards.firstWhere((c) => c.id == _selectedPaymentId);
    return '${card.brandLabel} •••• ${card.last4}';
  }

  Future<void> _handleChangeAddress() async {
    final selected = await Navigator.of(context).push<AddressModel>(
      MaterialPageRoute(builder: (_) => const AddressesScreen(selectMode: true)),
    );
    if (selected != null && mounted) {
      setState(() => _selectedAddress = selected);
    }
  }

  Future<void> _handlePlaceOrder() async {
    setState(() => _isPlacingOrder = true);

    final address = _selectedAddress!;
    final order = await _controller.placeOrder(
      paymentLabel: _selectedPaymentLabel,
      shippingAddress: '${address.addressLine}, ${address.shortLocation}',
    );

    if (!mounted) return;
    setState(() => _isPlacingOrder = false);

    await _showOrderPlacedDialog(order);
  }

  Future<void> _showOrderPlacedDialog(OrderModel order) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: AppColors.success,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 16),
            const Text(
              AppStrings.orderPlacedTitle,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              AppStrings.orderPlacedMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.only(bottom: 16),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
            child: const Text(
              AppStrings.viewOrders,
              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.home,
                    (route) => false,
              );
            },
            child: const Text(AppStrings.continueShopping),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          AppStrings.checkoutTitle,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _isLoading || _hasError ? null : _buildBottomBar(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const LoadingWidget();
    if (_hasError) return AppErrorWidget(onRetry: _loadData);

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _sectionTitle(AppStrings.shippingAddress),
        const SizedBox(height: 10),
        _buildAddressCard(),
        const SizedBox(height: 24),
        _sectionTitle(AppStrings.paymentMethod),
        const SizedBox(height: 10),
        _buildPaymentOptions(),
        const SizedBox(height: 24),
        _sectionTitle(AppStrings.orderSummary),
        const SizedBox(height: 10),
        _buildOrderSummary(),
        const SizedBox(height: 20),
      ],
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

  Widget _buildAddressCard() {
    final address = _selectedAddress!;
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
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.location_on_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  address.fullName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${address.addressLine}, ${address.shortLocation}',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _handleChangeAddress,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              AppStrings.changeLabel,
              style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentOptions() {
    return Column(
      children: [
        _PaymentOptionTile(
          icon: Icons.payments_outlined,
          label: AppStrings.cashOnDelivery,
          isSelected: _selectedPaymentId == 'cod',
          onTap: () => setState(() => _selectedPaymentId = 'cod'),
        ),
        for (final card in _cards) ...[
          const SizedBox(height: 10),
          _PaymentOptionTile(
            icon: Icons.credit_card_rounded,
            label: '${card.brandLabel} •••• ${card.last4}',
            isSelected: _selectedPaymentId == card.id,
            onTap: () => setState(() => _selectedPaymentId = card.id),
          ),
        ],
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _summaryRow(AppStrings.subtotalLabel, _controller.subtotal),
          const SizedBox(height: 10),
          _summaryRow(AppStrings.shippingFeeLabel, CheckoutController.shippingFee),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.border, height: 1),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.totalLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '\$${_controller.total.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, double amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Text(
          '\$${amount.toStringAsFixed(0)}',
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: CustomButton(
          label: AppStrings.placeOrder,
          isLoading: _isPlacingOrder,
          onPressed: _handlePlaceOrder,
        ),
      ),
    );
  }
}

class _PaymentOptionTile extends StatelessWidget {
  const _PaymentOptionTile({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppColors.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              size: 20,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}