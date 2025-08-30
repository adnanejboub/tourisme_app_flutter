import '../../../domain/product/entities/product.dart';
import '../../../data/static_data.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductEntity>> getProducts();
  Future<ProductEntity?> getProductById(String id);
  Future<List<ProductEntity>> getProductsByCategory(String categoryId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final dynamic apiClient; // Would be ApiClient in real implementation

  ProductRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ProductEntity>> getProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return StaticData.getProducts();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return StaticData.getProductById(id);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    return StaticData.getProductsByCategory(categoryId);
  }
}
