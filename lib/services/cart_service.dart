import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartService {
  CartService({ApiClient? apiClient}) : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  // Cached from the last server response so the synchronous
  // itemCount/subtotal getters (bottom-nav badge, Cart summary bar)
  // keep working without every call site becoming async-aware.
  // Refreshed after every call below, since every cart endpoint
  // returns the full updated cart.
  static List<CartItemModel> _cachedItems = [];
  static double _cachedSubtotal = 0;
  static int _cachedItemCount = 0;

  void _applyCartResponse(Map<String, dynamic> data) {
    final itemsJson = data['items'] as List<dynamic>? ?? [];
    _cachedItems = itemsJson.map((e) => CartItemModel.fromJson(e as Map<String, dynamic>)).toList();
    _cachedSubtotal = (data['subtotal'] as num?)?.toDouble() ?? 0;
    _cachedItemCount = (data['itemCount'] as num?)?.toInt() ?? 0;
  }

  Future<List<CartItemModel>> getCartItems() async {
    final response = await _apiClient.get(ApiEndpoints.cart, requiresAuth: true);
    if (!response.success) throw Exception(response.message);
    _applyCartResponse(response.data as Map<String, dynamic>? ?? {});
    return _cachedItems;
  }

  Future<void> addItem(ProductModel product, {int quantity = 1}) async {
    final response = await _apiClient.post(
      ApiEndpoints.cartItems,
      body: {'productId': product.id, 'quantity': quantity},
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
    _applyCartResponse(response.data as Map<String, dynamic>? ?? {});
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    final response = await _apiClient.put(
      '${ApiEndpoints.cartItems}/$productId',
      body: {'quantity': quantity},
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
    _applyCartResponse(response.data as Map<String, dynamic>? ?? {});
  }

  Future<void> removeItem(String productId) async {
    final response = await _apiClient.delete('${ApiEndpoints.cartItems}/$productId', requiresAuth: true);
    if (!response.success) throw Exception(response.message);
    _applyCartResponse(response.data as Map<String, dynamic>? ?? {});
  }

  Future<void> clearCart() async {
    final response = await _apiClient.delete(ApiEndpoints.cart, requiresAuth: true);
    if (!response.success) throw Exception(response.message);
    _applyCartResponse(response.data as Map<String, dynamic>? ?? {});
  }

  int get itemCount => _cachedItemCount;
  double get subtotal => _cachedSubtotal;
}