import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tourisme_app_flutter/domain/product/entities/product.dart';
import 'package:tourisme_app_flutter/domain/order/usecases/add_to_cart.dart';
import 'product_detail_state.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final AddToCart addToCart;
  ProductEntity? _product;

  ProductDetailCubit({required this.addToCart}) : super(ProductDetailState());

  void initialize(ProductEntity product) {
    _product = product;
    emit(state.copyWith(
      selectedColor: product.colors.isNotEmpty ? product.colors.first : null,
      selectedSize: product.sizes.isNotEmpty ? product.sizes.first : null,
    ));
  }

  void selectColor(String color) {
    emit(state.copyWith(selectedColor: color));
  }

  void selectSize(String size) {
    emit(state.copyWith(selectedSize: size));
  }

  void updateQuantity(int quantity) {
    if (quantity > 0) {
      emit(state.copyWith(quantity: quantity));
    }
  }

  Future<void> addProductToCart() async {
    if (_product == null) return;

    emit(state.copyWith(isAddingToCart: true, errorMessage: null));

    try {
      await addToCart(AddToCartParams(
        productId: _product!.id,
        quantity: state.quantity,
        color: state.selectedColor ?? '',
        size: state.selectedSize ?? '',
      ));
      
      emit(state.copyWith(isAddingToCart: false));
      // You might want to show a success message or navigate
    } catch (e) {
      emit(state.copyWith(
        isAddingToCart: false,
        errorMessage: e.toString(),
      ));
    }
  }
}