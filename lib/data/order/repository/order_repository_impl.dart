import '../../../domain/order/entities/cart_item.dart';
import '../../../domain/order/repository/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<CartItemEntity>> getCartProducts() async {
    return await remoteDataSource.getCartProducts();
  }

  @override
  Future<void> addToCart(String productId, int quantity, String color, String size) async {
    return await remoteDataSource.addToCart(productId, quantity, color, size);
  }

  @override
  Future<void> removeCartProduct(String itemId) async {
    return await remoteDataSource.removeCartProduct(itemId);
  }

  @override
  Future<void> updateCartItem(String itemId, int quantity) async {
    return await remoteDataSource.updateCartItem(itemId, quantity);
  }

  @override
  Future<String> orderRegistration(List<CartItemEntity> cartItems, String shippingAddress, String paymentMethod) async {
    return await remoteDataSource.orderRegistration(cartItems, shippingAddress, paymentMethod);
  }
}
