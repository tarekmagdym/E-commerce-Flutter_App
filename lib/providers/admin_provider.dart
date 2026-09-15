import 'package:flutter/foundation.dart';

import '../models/admin_stats_model.dart';
import '../models/category_model.dart';
import '../models/order_model.dart';
import '../models/paginated_response.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';

/// State for the whole admin dashboard. Every mutation calls the backend
/// first, then updates local state — screens just watch this provider.
class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();

  // ============ Dashboard ============
  AdminStatsModel? stats;
  List<SalesPoint> salesChart = [];
  List<OrderModel> recentOrders = [];
  String chartRange = 'week';
  bool dashboardLoading = false;
  String? dashboardError;

  Future<void> loadDashboard() async {
    dashboardLoading = true;
    dashboardError = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _adminService.getDashboardStats(),
        _adminService.getSalesChart(chartRange),
        _adminService.getRecentOrders(),
      ]);
      stats = results[0] as AdminStatsModel;
      salesChart = results[1] as List<SalesPoint>;
      recentOrders = results[2] as List<OrderModel>;
    } catch (e) {
      dashboardError = e.toString();
    }
    dashboardLoading = false;
    notifyListeners();
  }

  Future<void> setChartRange(String range) async {
    if (chartRange == range) return;
    chartRange = range;
    notifyListeners();
    try {
      salesChart = await _adminService.getSalesChart(range);
    } catch (_) {}
    notifyListeners();
  }

  // ============ Orders ============
  Paginated<OrderModel> orders = Paginated.empty();
  String orderStatusFilter = '';
  bool ordersLoading = false;
  String? ordersError;

  Future<void> loadOrders({bool reset = true}) async {
    if (reset) orders = Paginated.empty();
    ordersLoading = true;
    ordersError = null;
    notifyListeners();
    try {
      final res = await _adminService.getOrders(
        status: orderStatusFilter.isEmpty ? null : orderStatusFilter,
        page: reset ? 1 : orders.page + 1,
      );
      orders = reset ? res : orders.append(res);
    } catch (e) {
      ordersError = e.toString();
    }
    ordersLoading = false;
    notifyListeners();
  }

  Future<void> setOrderStatusFilter(String status) async {
    orderStatusFilter = status;
    await loadOrders();
  }

  /// Returns null on success, error message on failure.
  Future<String?> updateOrderStatus(String orderId, String status) async {
    try {
      final updated = await _adminService.updateOrderStatus(orderId, status);
      orders = orders.replaceItem((o) => o.id == orderId, updated);
      recentOrders =
          recentOrders.map((o) => o.id == orderId ? updated : o).toList();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ============ Users ============
  Paginated<UserModel> users = Paginated.empty();
  String userSearch = '';
  bool usersLoading = false;
  String? usersError;

  Future<void> loadUsers({bool reset = true}) async {
    if (reset) users = Paginated.empty();
    usersLoading = true;
    usersError = null;
    notifyListeners();
    try {
      final res = await _adminService.getUsers(
        search: userSearch.isEmpty ? null : userSearch,
        page: reset ? 1 : users.page + 1,
      );
      users = reset ? res : users.append(res);
    } catch (e) {
      usersError = e.toString();
    }
    usersLoading = false;
    notifyListeners();
  }

  Future<void> searchUsers(String query) async {
    userSearch = query;
    await loadUsers();
  }

  Future<String?> updateUser(String id,
      {String? role, bool? isBlocked, String? fullName, String? phone}) async {
    try {
      final updated = await _adminService.updateUser(id,
          role: role, isBlocked: isBlocked, fullName: fullName, phone: phone);
      users = users.replaceItem((u) => u.id == id, updated);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleBlockUser(UserModel user) =>
      updateUser(user.id, isBlocked: !user.isBlocked);

  Future<String?> deleteUser(String id) async {
    try {
      await _adminService.deleteUser(id);
      users = users.removeWhere((u) => u.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ============ Products ============
  Paginated<ProductModel> products = Paginated.empty();
  String productSearch = '';
  bool productsLoading = false;
  String? productsError;

  Future<void> loadProducts({bool reset = true}) async {
    if (reset) products = Paginated.empty();
    productsLoading = true;
    productsError = null;
    notifyListeners();
    try {
      final res = await _productService.getProducts(
        search: productSearch.isEmpty ? null : productSearch,
        page: reset ? 1 : products.page + 1,
        all: true,
      );
      products = reset ? res : products.append(res);
    } catch (e) {
      productsError = e.toString();
    }
    productsLoading = false;
    notifyListeners();
  }

  Future<void> searchProducts(String query) async {
    productSearch = query;
    await loadProducts();
  }

  Future<String?> deleteProduct(String id) async {
    try {
      await _productService.deleteProduct(id);
      products = products.removeWhere((p) => p.id == id);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> toggleProductActive(ProductModel product) async {
    try {
      final updated =
          await _productService.updateProduct(product.id, isActive: !product.isActive);
      products = products.replaceItem((p) => p.id == product.id, updated);
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // ============ Categories ============
  List<CategoryModel> categories = [];
  bool categoriesLoading = false;
  String? categoriesError;

  Future<void> loadCategories() async {
    categoriesLoading = true;
    categoriesError = null;
    notifyListeners();
    try {
      categories = await _categoryService.getCategories();
    } catch (e) {
      categoriesError = e.toString();
    }
    categoriesLoading = false;
    notifyListeners();
  }

  Future<String?> deleteCategory(String id) async {
    try {
      await _categoryService.deleteCategory(id);
      categories = categories.where((c) => c.id != id).toList();
      notifyListeners();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}