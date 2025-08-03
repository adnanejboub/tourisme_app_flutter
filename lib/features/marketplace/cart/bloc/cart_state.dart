import 'package:tourisme_app_flutter/domain/order/entities/cart_item.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItemEntity> items;
  final double total;

  CartLoaded({required this.items, required this.total});
}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}