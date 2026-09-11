class AddressModel {
  const AddressModel({
    required this.id,
    required this.fullName,
    required this.addressLine,
    required this.city,
    required this.country,
    this.isDefault = false,
  });

  final String id;
  final String fullName;
  final String addressLine;
  final String city;
  final String country;
  final bool isDefault;

  String get shortLocation => '$city, $country';
}