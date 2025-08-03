import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../repository/order_repository.dart';

class UpdateCartItemParams {
  final String itemId;
  final int quantity;

  UpdateCartItemParams({
    required this.itemId,
    required this.quantity,
  });
}

class UpdateCartItem extends UseCase<void, UpdateCartItemParams> {
  final OrderRepository repository;

  UpdateCartItem(this.repository);

  @override
  Future<void> call(UpdateCartItemParams params) async {
    return await repository.updateCartItem(params.itemId, params.quantity);
  }
}