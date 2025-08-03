import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repository/order_repository.dart';

class GetCartProducts extends UseCase<List<CartItemEntity>, NoParams> {
  final OrderRepository repository;

  GetCartProducts(this.repository);

  @override
  Future<List<CartItemEntity>> call(NoParams params) async {
    return await repository.getCartProducts();
  }
}