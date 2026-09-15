import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';

/// Everything the Home screen needs, loaded in one shot.
class HomeData {
  const HomeData({
    required this.categories,
    required this.bestSellers,
    required this.allProducts,
  });

  final List<CategoryModel> categories;
  final List<ProductModel> bestSellers;
  final List<ProductModel> allProducts;
}

class HomeController {
  HomeController({
    ProductService? productService,
    CategoryService? categoryService,
  })  : _productService = productService ?? ProductService(),
        _categoryService = categoryService ?? CategoryService();

  final ProductService _productService;
  final CategoryService _categoryService;

  Future<List<CategoryModel>> loadCategories() {
    return _categoryService.getCategories();
  }

  Future<List<ProductModel>> loadBestSellers() {
    return _productService.getBestSellers();
  }

  Future<List<ProductModel>> loadProducts() {
    return _productService.getAllProducts();
  }

  /// Loads categories + best sellers + the catalog in parallel.
  ///
  /// If /products/best-sellers fails or comes back empty we fall back to the
  /// first few products so the section never renders blank.
  Future<HomeData> loadHomeData() async {
    final results = await Future.wait([
      _categoryService.getCategories(),
      _loadBestSellersSafe(),
      _productService.getAllProducts(),
    ]);

    final categories = results[0] as List<CategoryModel>;
    final allProducts = results[2] as List<ProductModel>;
    var bestSellers = results[1] as List<ProductModel>;

    if (bestSellers.isEmpty) {
      bestSellers = allProducts.take(6).toList();
    }

    return HomeData(
      categories: categories,
      bestSellers: bestSellers,
      allProducts: allProducts,
    );
  }

  Future<List<ProductModel>> _loadBestSellersSafe() async {
    try {
      return await _productService.getBestSellers();
    } catch (_) {
      return const <ProductModel>[];
    }
  }
}