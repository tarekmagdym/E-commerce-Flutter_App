import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';

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
}