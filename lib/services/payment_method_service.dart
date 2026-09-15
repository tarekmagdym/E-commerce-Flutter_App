import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/payment_method_model.dart';

class PaymentMethodService {
  PaymentMethodService({ApiClient? apiClient}) : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await _apiClient.get(ApiEndpoints.paymentMethods, requiresAuth: true);
    if (!response.success) throw Exception(response.message);
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => PaymentMethodModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// brand: 'visa' | 'mastercard' | 'other'. Never send a full card
  /// number or CVV — the backend schema deliberately doesn't store
  /// them, only last4 + expiry (MM/YY).
  Future<PaymentMethodModel> addPaymentMethod({
    required String brand,
    required String last4,
    required String expiry,
    bool isDefault = false,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.paymentMethods,
      body: {'brand': brand, 'last4': last4, 'expiry': expiry, 'isDefault': isDefault},
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
    return PaymentMethodModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  Future<void> setDefault(String id) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.paymentMethods}/$id/default',
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
  }

  Future<void> deletePaymentMethod(String id) async {
    final response = await _apiClient.delete('${ApiEndpoints.paymentMethods}/$id', requiresAuth: true);
    if (!response.success) throw Exception(response.message);
  }
}