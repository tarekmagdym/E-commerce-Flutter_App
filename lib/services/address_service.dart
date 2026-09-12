import '../models/address_model.dart';

/// New service (not part of the original scaffold), mocking saved
/// addresses for the Addresses screen under Profile and for
/// Checkout's shipping-address selection.
class AddressService {
  static final List<AddressModel> _addresses = [
    const AddressModel(
      id: 'addr1',
      fullName: 'Tarek Magdy',
      addressLine: '12 Nile Street, Building 4',
      city: 'Cairo',
      country: 'Egypt',
      isDefault: true,
    ),
    const AddressModel(
      id: 'addr2',
      fullName: 'Tarek Magdy',
      addressLine: '5 Corniche Road, Apartment 9',
      city: 'Alexandria',
      country: 'Egypt',
    ),
  ];

  Future<List<AddressModel>> getAddresses() async {
    // Real call will be: GET /addresses
    await Future.delayed(const Duration(milliseconds: 400));
    return List.unmodifiable(_addresses);
  }

  void setDefault(String id) {
    for (var i = 0; i < _addresses.length; i++) {
      _addresses[i] = _addresses[i].copyWith(isDefault: _addresses[i].id == id);
    }
  }

  void removeAddress(String id) {
    _addresses.removeWhere((a) => a.id == id);
  }
}