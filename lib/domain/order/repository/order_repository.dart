import '../entities/cart_item.dart';

abstract class OrderRepository {
  Future<List<CartItemEntity>> getCartProducts();
  Future<void> addToCart(String productId, int quantity, String color, String size);
  Future<void> removeCartProduct(String itemId);
  Future<void> updateCartItem(String itemId, int quantity);
  Future<String> orderRegistration(List<CartItemEntity> cartItems, String shippingAddress, String paymentMethod);
}
