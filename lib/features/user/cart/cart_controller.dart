import '../../../models/cart_model.dart';
import '../../../models/product_model.dart';
import '../../../services/cart_service.dart';

/// Mirrors HomeController/CategoriesController's shape.
class CartController {
  CartController({CartService? cartService}) : _service = cartService ?? CartService();

  final CartService _service;

  Future<List<CartItemModel>> loadCart() => _service.getCartItems();

  Future<void> addItem(ProductModel product, {int quantity = 1}) {
    return _service.addItem(product, quantity: quantity);
  }

  Future<void> updateQuantity(String productId, int quantity) {
    return _service.updateQuantity(productId, quantity);
  }

  Future<void> removeItem(String productId) => _service.removeItem(productId);

  Future<void> clearCart() => _service.clearCart();

  int get itemCount => _service.itemCount;

  double get subtotal => _service.subtotal;
}