import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repository/order_repository.dart';

class OrderRegistrationParams {
  final List<CartItemEntity> cartItems;
  final String shippingAddress;
  final String paymentMethod;

  OrderRegistrationParams({
    required this.cartItems,
    required this.shippingAddress,
    required this.paymentMethod,
  });
}

class OrderRegistration extends UseCase<String, OrderRegistrationParams> {
  final OrderRepository repository;

  OrderRegistration(this.repository);

  @override
  Future<String> call(OrderRegistrationParams params) async {
    return await repository.orderRegistration(
      params.cartItems,
      params.shippingAddress,
      params.paymentMethod,
    );
  }
}