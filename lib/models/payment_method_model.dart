enum CardBrand { visa, mastercard, other }

/// New model (not part of the original scaffold) backing the
/// Payment Methods screen under Profile.
class PaymentMethodModel {
  const PaymentMethodModel({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiry,
    this.isDefault = false,
  });

  final String id;
  final CardBrand brand;
  final String last4;
  final String expiry; // MM/YY
  final bool isDefault;

  String get brandLabel {
    switch (brand) {
      case CardBrand.visa:
        return 'Visa';
      case CardBrand.mastercard:
        return 'Mastercard';
      case CardBrand.other:
        return 'Card';
    }
  }

  PaymentMethodModel copyWith({bool? isDefault}) {
    return PaymentMethodModel(
      id: id,
      brand: brand,
      last4: last4,
      expiry: expiry,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
