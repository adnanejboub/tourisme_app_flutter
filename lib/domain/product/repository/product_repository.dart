import '../entities/product.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity?> getProductById(String id);
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);
}