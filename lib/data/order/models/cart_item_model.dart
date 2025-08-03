import '../../../domain/order/entities/cart_item.dart';
import '../../../domain/product/entities/product.dart';
import '../../product/models/product_model.dart';

class CartItemModel extends CartItemEntity {
  CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    required super.selectedColor,
    required super.selectedSize,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'],
      product: ProductModel.fromJson(json['product']),
      quantity: json['quantity'],
      selectedColor: json['selectedColor'],
      selectedSize: json['selectedSize'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
      'selectedColor': selectedColor,
      'selectedSize': selectedSize,
    };
  }
}
