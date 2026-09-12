import '../../../models/address_model.dart';
import '../../../models/cart_model.dart';
import '../../../models/order_model.dart';
import '../../../models/payment_method_model.dart';
import '../../../services/cart_service.dart';
import '../../../services/order_service.dart';
import '../../../services/payment_method_service.dart';
import '../../../services/address_service.dart';

/// Loads the data the Checkout screen needs and places the order.
/// Mirrors HomeController/CategoriesController's shape.
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

  static const double shippingFee = 50;

  /// Fallback used only if the Addresses screen's list is ever empty.
  static const AddressModel _fallbackAddress = AddressModel(
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

  /// Loads the address to show by default: the saved default address,
  /// or the first saved address, or a fallback if none are saved yet.
  Future<AddressModel> loadShippingAddress() async {
    final addresses = await _addressService.getAddresses();
    if (addresses.isEmpty) return _fallbackAddress;
    return addresses.firstWhere((a) => a.isDefault, orElse: () => addresses.first);
  }

  double get subtotal => _cartService.subtotal;

  double get total => subtotal + shippingFee;

  Future<OrderModel> placeOrder({
    required String paymentLabel,
    required String shippingAddress,
  }) async {
    final items = await _cartService.getCartItems();
    final itemCount = items.fold<int>(0, (sum, item) => sum + item.quantity);

    final order = await _orderService.placeOrder(
      total: total,
      itemCount: itemCount,
      items: items,
      shippingAddress: shippingAddress,
      paymentLabel: paymentLabel,
    );

    await _cartService.clearCart();
    return order;
  }
}