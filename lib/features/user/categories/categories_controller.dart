import '../../../models/category_model.dart';
import '../../../models/product_model.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';

/// Loads the data the Categories screen needs. Mirrors [HomeController]'s
/// shape so both screens stay easy to read side by side.
class CategoriesController {
  CategoriesController({
    ProductService? productService,
    CategoryService? categoryService,
  })  : _productService = productService ?? ProductService(),
        _categoryService = categoryService ?? CategoryService();

  final ProductService _productService;
  final CategoryService _categoryService;

  Future<List<CategoryModel>> loadCategories() {
    return _categoryService.getCategories();
  }

  Future<List<ProductModel>> loadProducts() {
    return _productService.getAllProducts();
  }
}
