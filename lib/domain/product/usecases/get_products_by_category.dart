import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repository/product_repository.dart';

class GetProductsByCategory extends UseCase<List<ProductEntity>, String> {
  final ProductRepository repository;

  GetProductsByCategory(this.repository);

  @override
  Future<List<ProductEntity>> call(String categoryId) async {
    return await repository.getProductsByCategory(categoryId);
  }
}