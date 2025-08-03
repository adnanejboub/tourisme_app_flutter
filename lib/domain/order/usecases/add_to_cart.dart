import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../repository/order_repository.dart';

class AddToCartParams {
  final String productId;
  final int quantity;
  final String color;
  final String size;

  AddToCartParams({
    required this.productId,
    required this.quantity,
    required this.color,
    required this.size,
  });
}

class AddToCart extends UseCase<void, AddToCartParams> {
  final OrderRepository repository;

  AddToCart(this.repository);

  @override
  Future<void> call(AddToCartParams params) async {
    return await repository.addToCart(
      params.productId,
      params.quantity,
      params.color,
      params.size,
    );
  }
}