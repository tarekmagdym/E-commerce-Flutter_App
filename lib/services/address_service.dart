import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/address_model.dart';

/// Wired to the real backend. NOTE: userController.js (which owns
/// /users/me/addresses) wasn't available when this was written —
/// PUT's expected body and whether it auto-unsets other defaults are
/// inferred from this backend's consistent patterns elsewhere
/// (Category/PaymentMethod both do explicit "unset all, then set
/// one" for isDefault). If PUT here behaves differently, setDefault()
/// below is the one place to fix.
class AddressService {
  AddressService({ApiClient? apiClient}) : _apiClient = apiClient ?? const ApiClient();

  final ApiClient _apiClient;

  Future<List<AddressModel>> getAddresses() async {
    final response = await _apiClient.get(ApiEndpoints.userAddresses, requiresAuth: true);
    if (!response.success) throw Exception(response.message);
    final list = response.data as List<dynamic>? ?? [];
    return list.map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<AddressModel> addAddress(AddressModel address) async {
    final response = await _apiClient.post(
      ApiEndpoints.userAddresses,
      body: address.toJson(),
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
    return AddressModel.fromJson(response.data as Map<String, dynamic>? ?? {});
  }

  Future<void> setDefault(String id) async {
    final addresses = await getAddresses();
    final target = addresses.firstWhere((a) => a.id == id);
    final response = await _apiClient.put(
      '${ApiEndpoints.userAddresses}/$id',
      body: target.copyWith(isDefault: true).toJson(),
      requiresAuth: true,
    );
    if (!response.success) throw Exception(response.message);
  }

  Future<void> removeAddress(String id) async {
    final response = await _apiClient.delete('${ApiEndpoints.userAddresses}/$id', requiresAuth: true);
    if (!response.success) throw Exception(response.message);
  }
}