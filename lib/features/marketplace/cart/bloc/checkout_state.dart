abstract class CheckoutState {}

class CheckoutInitial extends CheckoutState {}

class CheckoutLoading extends CheckoutState {}

class CheckoutSuccess extends CheckoutState {
  final String orderId;

  CheckoutSuccess(this.orderId);
}

class CheckoutError extends CheckoutState {
  final String message;

  CheckoutError(this.message);
}