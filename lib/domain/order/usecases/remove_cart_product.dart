import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../repository/order_repository.dart';

class RemoveCartProduct extends UseCase<void, String> {
  final OrderRepository repository;

  RemoveCartProduct(this.repository);

  @override
  Future<void> call(String itemId) async {
    return await repository.removeCartProduct(itemId);
  }
}
