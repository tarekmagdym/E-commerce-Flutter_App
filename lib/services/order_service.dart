import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/order_model.dart';

/// User-facing order operations, all real now. GET /orders and
/// GET /orders/:id were already wired; placeOrder() below now calls
/// the real POST /orders, which reads the server-side Cart directly —
/// no items are sent from the client. Admin order management lives
/// in AdminService, not here.
class OrderService {
  OrderService({ApiClient? apiClient}) : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  Future<List<OrderModel>> getOrders() async {
    final response = await _apiClient.get(ApiEndpoints.orders, requiresAuth: true);
    if (!response.success) throw Exception(response.message);
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<OrderModel> getOrderById(String id) async {
    final response = await _apiClient.get('${ApiEndpoints.orders}/$id', requiresAuth: true);
    if (!response.success) throw Exception(response.message);
    return OrderModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  /// POST /orders — reads the user's server-side cart, creates the
  /// order, decrements stock, and clears the cart, all server-side.
  /// Body: { addressId, paymentMethodId? } — paymentMethodId omitted
  /// for Cash on Delivery, which the backend already defaults
  /// gracefully to { brand: 'other', last4: '' }.
  Future<OrderModel> placeOrder({
    required String addressId,
    String? paymentMethodId,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      body: {
        'addressId': addressId,
        if (paymentMethodId != null) 'paymentMethodId': paymentMethodId,
      },
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
    return OrderModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }
}