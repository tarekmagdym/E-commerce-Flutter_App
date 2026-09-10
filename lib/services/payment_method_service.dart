import '../models/payment_method_model.dart';

/// New service (not part of the original scaffold), mocking saved
/// cards for the Payment Methods screen under Profile.
class PaymentMethodService {
  static const List<PaymentMethodModel> _cards = [
    PaymentMethodModel(
      id: 'pm1',
      brand: CardBrand.visa,
      last4: '4242',
      expiry: '09/28',
      isDefault: true,
    ),
    PaymentMethodModel(
      id: 'pm2',
      brand: CardBrand.mastercard,
      last4: '8410',
      expiry: '03/27',
    ),
  ];

  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    // Real call will be: GET /payment-methods
    await Future.delayed(const Duration(milliseconds: 400));
    return _cards;
  }
}
