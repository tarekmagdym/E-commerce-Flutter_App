import '../../../models/address_model.dart';
import '../../../models/cart_model.dart';
import '../../../models/order_model.dart';
import '../../../models/payment_method_model.dart';
import '../../../services/address_service.dart';
import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../../services/payment_method_service.dart';

class CheckoutController {
  CheckoutController({
    CartService? cartService,
    OrderService? orderService,
    PaymentMethodService? paymentMethodService,
    AddressService? addressService,
  })  : _cartService = cartService ?? CartService(),
        _orderService = orderService ?? OrderService(),
        _paymentMethodService = paymentMethodService ?? PaymentMethodService(),
        _addressService = addressService ?? AddressService();

  final CartService _cartService;
  final OrderService _orderService;
  final PaymentMethodService _paymentMethodService;
  final AddressService _addressService;

  Future<List<CartItemModel>> loadCartItems() => _cartService.getCartItems();

  Future<List<PaymentMethodModel>> loadPaymentMethods() {
    return _paymentMethodService.getPaymentMethods();
  }

  Future<List<AddressModel>> loadAddresses() => _addressService.getAddresses();

  /// The default saved address, or the first one — null if the user
  /// has none saved yet (Checkout should prompt them to add one).
  Future<AddressModel?> loadDefaultAddress() async {
    final addresses = await loadAddresses();
    if (addresses.isEmpty) return null;
    return addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
  }

  double get subtotal => _cartService.subtotal;

  /// Shipping is computed server-side (currently a flat rate, see
  /// orderController.js's SHIPPING_FEE) — shown as an estimate here
  /// until the real order confirms the actual total.
  double get total => subtotal;

  Future<OrderModel> placeOrder({
    required String addressId,
    String? paymentMethodId,
  }) {
    return _orderService.placeOrder(addressId: addressId, paymentMethodId: paymentMethodId);
  }
}