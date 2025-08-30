import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourisme_app_flutter/domain/order/entities/cart_item.dart';
import 'package:tourisme_app_flutter/domain/order/usecases/order_registration.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  final OrderRegistration orderRegistration;

  CheckoutCubit({required this.orderRegistration}) : super(CheckoutInitial());

  Future<void> placeOrder(List<CartItemEntity> items) async {
    emit(CheckoutLoading());
    try {
      final orderId = await orderRegistration(OrderRegistrationParams(
        cartItems: items,
        shippingAddress: 'Default shipping address',
        paymentMethod: 'Credit Card',
      ));
      emit(CheckoutSuccess(orderId));
    } catch (e) {
      emit(CheckoutError(e.toString()));
    }
  }
}