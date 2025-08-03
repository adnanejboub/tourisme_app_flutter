import '../../../domain/order/entities/cart_item.dart';
import '../../../data/static_data.dart';

abstract class OrderRemoteDataSource {
  Future<List<CartItemEntity>> getCartProducts();
  Future<void> addToCart(String productId, int quantity, String color, String size);
  Future<void> removeCartProduct(String itemId);
  Future<void> updateCartItem(String itemId, int quantity);
  Future<String> orderRegistration(List<CartItemEntity> cartItems, String shippingAddress, String paymentMethod);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final dynamic apiClient; // Would be ApiClient in real implementation

  OrderRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CartItemEntity>> getCartProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    return StaticData.getCartItems();
  }

  @override
  Future<void> addToCart(String productId, int quantity, String color, String size) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 400));
    StaticData.addToCart(productId, quantity, color, size);
  }

  @override
  Future<void> removeCartProduct(String itemId) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    StaticData.removeFromCart(itemId);
  }

  @override
  Future<void> updateCartItem(String itemId, int quantity) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    StaticData.updateCartItemQuantity(itemId, quantity);
  }

  @override
  Future<String> orderRegistration(List<CartItemEntity> cartItems, String shippingAddress, String paymentMethod) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 1000));
    // Generate order ID
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}