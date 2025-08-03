import '../../product/entities/product.dart';

class CartItemEntity {
  final String id;
  final ProductEntity product;
  final int quantity;
  final String selectedColor;
  final String selectedSize;

  CartItemEntity({
    required this.id,
    required this.product,
    required this.quantity,
    required this.selectedColor,
    required this.selectedSize,
  });
}