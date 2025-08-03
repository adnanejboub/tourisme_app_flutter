import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repository/product_repository.dart';

class GetProductById extends UseCase<ProductEntity?, String> {
  final ProductRepository repository;

  GetProductById(this.repository);

  @override
  Future<ProductEntity?> call(String id) async {
    return await repository.getProductById(id);
  }
}