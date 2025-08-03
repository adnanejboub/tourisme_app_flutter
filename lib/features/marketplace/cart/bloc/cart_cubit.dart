import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourisme_app_flutter/domain/order/usecases/get_cart_products.dart';
import 'package:tourisme_app_flutter/domain/order/usecases/remove_cart_product.dart';
import 'package:tourisme_app_flutter/domain/order/usecases/update_cart_item.dart';
import 'package:tourisme_app_flutter/core/usecases/usecase.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  final GetCartProducts getCartProducts;
  final RemoveCartProduct removeFromCart;
  final UpdateCartItem updateCartItem;

  CartCubit({
    required this.getCartProducts,
    required this.removeFromCart,
    required this.updateCartItem,
  }) : super(CartInitial());

  Future<void> loadCart() async {
    emit(CartLoading());
    try {
      final items = await getCartProducts(NoParams());
      final total = _calculateTotal(items);
      emit(CartLoaded(items: items, total: total));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> removeItem(String itemId) async {
    try {
      await removeFromCart(itemId);
      loadCart(); // Reload cart after removal
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> updateItemQuantity(String itemId, int quantity) async {
    try {
      await updateCartItem(UpdateCartItemParams(itemId: itemId, quantity: quantity));
      loadCart(); // Reload cart after update
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  double _calculateTotal(List items) {
    return items.fold(0.0, (total, item) {
      final price = item.product.discountedPrice > 0 
          ? item.product.discountedPrice 
          : item.product.price;
      return total + (price * item.quantity);
    });
  }
}
