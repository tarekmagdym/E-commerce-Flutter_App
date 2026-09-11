import '../../../models/address_model.dart';
import '../../../models/cart_model.dart';
import '../../../models/order_model.dart';
import '../../../models/payment_method_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../../services/payment_method_service.dart';

/// Loads the data the Checkout screen needs and places the order.
/// Mirrors HomeController/CategoriesController's shape.
class CheckoutController {
  CheckoutController({
    CartService? cartService,
    OrderService? orderService,
    PaymentMethodService? paymentMethodService,
  })  : _cartService = cartService ?? CartService(),
        _orderService = orderService ?? OrderService(),
        _paymentMethodService = paymentMethodService ?? PaymentMethodService();

  final CartService _cartService;
  final OrderService _orderService;
  final PaymentMethodService _paymentMethodService;

  static const double shippingFee = 50;

  /// Addresses screen isn't built yet, so Checkout uses one fixed
  /// mock address for now. Swap for a real selection flow later.
  static const AddressModel defaultAddress = AddressModel(
    id: 'addr1',
    fullName: 'Tarek Magdy',
    addressLine: '12 Nile Street, Building 4',
    city: 'Cairo',
    country: 'Egypt',
    isDefault: true,
  );

  Future<List<CartItemModel>> loadCartItems() => _cartService.getCartItems();

  Future<List<PaymentMethodModel>> loadPaymentMethods() {
    return _paymentMethodService.getPaymentMethods();
  }

  double get subtotal => _cartService.subtotal;

  double get total => subtotal + shippingFee;

  Future<OrderModel> placeOrder() async {
    final items = await _cartService.getCartItems();
    final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);

    final order = await _orderService.placeOrder(
      total: total,
      itemCount: itemCount,
    );

    await _cartService.clearCart();
    return order;
  }
}