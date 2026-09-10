import '../../../models/user_model.dart';
import '../../../services/order_service.dart';
import '../../../services/product_service.dart';
import '../../../services/user_service.dart';

/// Loads the data the Profile screen needs. Mirrors [HomeController]'s
/// shape so the codebase stays consistent screen to screen.
class ProfileController {
  ProfileController({
    UserService? userService,
    OrderService? orderService,
    ProductService? productService,
  })  : _userService = userService ?? UserService(),
        _orderService = orderService ?? OrderService(),
        _productService = productService ?? ProductService();

  final UserService _userService;
  final OrderService _orderService;
  final ProductService _productService;

  Future<UserModel> loadUser() {
    return _userService.getCurrentUser();
  }

  Future<int> loadOrdersCount() async {
    final orders = await _orderService.getOrders();
    return orders.length;
  }

  Future<int> loadWishlistCount() async {
    final wishlist = await _productService.getWishlist();
    return wishlist.length;
  }

  Future<void> logout() {
    return _userService.logout();
  }
}
