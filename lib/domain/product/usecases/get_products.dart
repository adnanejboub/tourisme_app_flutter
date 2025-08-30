import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repository/product_repository.dart';

class GetProducts extends UseCase<List<ProductEntity>, NoParams> {
  final ProductRepository repository;

  GetProducts(this.repository);

  @override
  Future<List<ProductEntity>> call(NoParams params) async {
    return await repository.getProducts();
  }
}