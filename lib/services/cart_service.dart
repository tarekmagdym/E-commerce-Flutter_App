import '../models/cart_model.dart';
import '../models/product_model.dart';

/// Mock, in-memory cart. The list is `static` so it survives switching
/// between bottom-nav tabs within the same app session — there's no
/// backend yet to persist it, and no global state package
/// (Provider/Riverpod) wired up yet either.
///
/// TODO: once the backend exists, replace the static list with real
/// GET/POST/PATCH/DELETE calls to /cart.
class CartService {
  static final List<CartItemModel> _items = [];

  Future<List<CartItemModel>> getCartItems() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_items);
  }

  Future<void> addItem(ProductModel product, {int quantity = 1}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index == -1) {
      _items.add(CartItemModel(product: product, quantity: quantity));
    } else {
      _items[index] = _items[index].copyWith(
        quantity: _items[index].quantity + quantity,
      );
    }
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index == -1) return;

    if (quantity <= 0) {
      _items.removeAt(index);
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
  }

  Future<void> removeItem(String productId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _items.removeWhere((item) => item.product.id == productId);
  }

  Future<void> clearCart() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _items.clear();
  }

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.lineTotal);
}