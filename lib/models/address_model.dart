class AddressModel {
  const AddressModel({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.street,
    required this.city,
    this.state = '',
    required this.country,
    this.postalCode = '',
    this.label = 'Home',
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String fullName;
  final String phone;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final bool isDefault;

  String get addressLine => street;
  String get shortLocation => state.isEmpty ? '$city, $country' : '$city, $state, $country';

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    return AddressModel(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      label: json['label'] as String? ?? 'Home',
      fullName: json['fullName'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'label': label,
    'fullName': fullName,
    'phone': phone,
    'street': street,
    'city': city,
    'state': state,
    'country': country,
    'postalCode': postalCode,
    'isDefault': isDefault,
  };

  AddressModel copyWith({bool? isDefault}) {
    return AddressModel(
      id: id,
      label: label,
      fullName: fullName,
      phone: phone,
      street: street,
      city: city,
      state: state,
      country: country,
      postalCode: postalCode,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}