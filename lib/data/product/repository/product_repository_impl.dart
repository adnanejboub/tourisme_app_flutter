import '../../../domain/product/entities/product.dart';
import '../../../domain/product/repository/product_repository.dart';
import '../datasources/product_remote_data_source.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<ProductEntity>> getProducts() async {
    return await remoteDataSource.getProducts();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    return await remoteDataSource.getProductById(id);
  }

  @override
  Future<List<ProductEntity>> getProductsByCategory(String categoryId) async {
    return await remoteDataSource.getProductsByCategory(categoryId);
  }
}