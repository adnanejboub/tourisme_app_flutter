import '../domain/product/entities/product.dart';
import '../domain/category/entities/category.dart';
import '../domain/order/entities/cart_item.dart';

class StaticData {
  static List<CartItemEntity> _cartItems = [];

  static final List<CategoryEntity> categories = [
    CategoryEntity(
      id: '1',
      title: 'All',
    ),CategoryEntity(
      id: '2',
      title: 'Crafts',
    ),
    CategoryEntity(
      id: '3', 
      title: 'Pottery',
    ),
    CategoryEntity(
      id: '4',
      title: 'Leather',
    ),
    CategoryEntity(
      id: '5',
      title: 'Textiles',
    ),
    CategoryEntity(
      id: '6',
      title: 'Jewelry',
    ),
    CategoryEntity(
      id: '7',
      title: 'Spices',
    ),
    CategoryEntity(
      id: '8',
      title: 'Home Decor',
    ),
    CategoryEntity(
      id: '9',
      title: 'Cosmetics',
    ),
  ];

  static final List<ProductEntity> products = [
  ProductEntity(
    id: '1',
    title: 'Argan Oil',
    description: 'Pure Moroccan argan oil for skin, hair, and culinary uses. Known for its nourishing and anti-aging properties.',
    price: 29.99,
    discountedPrice: 24,
    image: 'https://terrebrune.ma/cdn/shop/products/1_df7ce0f3-a311-43d0-8b53-d0e8b95c499c.png?v=1640013302',
    categoryId: '2', // Crafts
    colors: [],
    sizes: ['100ml', '250ml'],
    isFavorite: true,
  ),
  ProductEntity(
    id: '2',
    title: 'Zaafaran (Saffron)',
    description: 'Premium hand-harvested saffron threads from the Atlas Mountains, prized for flavor and color.',
    price: 14.99,
    discountedPrice: 12,
    image: 'https://5.imimg.com/data5/SELLER/Default/2022/1/HD/FJ/HM/111935069/baby-saffron-main.jpg',
    categoryId: '2', // Crafts
    colors: [],
    sizes: ['1g', '5g'],
    isFavorite: false,
  ),
  ProductEntity(
    id: '3',
    title: 'Hand-Painted Ceramic Plate',
    description: 'Traditional Moroccan ceramic plate with intricate geometric patterns, perfect for decoration or serving.',
    price: 39.99,
    discountedPrice: 29,
    image: 'https://i.etsystatic.com/25844243/r/il/0ee5b3/4551523770/il_570xN.4551523770_eodb.jpg',
    categoryId: '3', // Pottery
    colors: ['Blue', 'Green', 'Multi'],
    sizes: ['Medium', 'Large'],
    isFavorite: false,
  ),
  ProductEntity(
    id: '4',
    title: 'Leather Pouf',
    description: 'Hand-stitched leather pouf ottoman, made from genuine Moroccan leather, ideal for home décor.',
    price: 89.99,
    discountedPrice: 74,
    image: 'https://mytindy.com/cdn/shop/products/CVuEpxCMc8.jpg?v=1629710322',
    categoryId: '4', // Leather
    colors: ['Brown', 'Tan', 'White'],
    sizes: ['Standard'],
    isFavorite: true,
  ),
  ProductEntity(
    id: '5',
    title: 'Berber Rug',
    description: 'Handwoven Berber rug made from natural wool, featuring traditional Amazigh symbols and patterns.',
    price: 299.99,
    discountedPrice: 249,
    image: 'https://www.e-mosaik.com/cdn/shop/products/dsa_0449_2048x.jpg?v=1517560654',
    categoryId: '5', // Textiles
    colors: ['White', 'Black', 'Red'],
    sizes: ['Small', 'Medium', 'Large'],
    isFavorite: false,
  ),
  ProductEntity(
    id: '6',
    title: 'Silver Berber Necklace',
    description: 'Handcrafted silver necklace with traditional Berber motifs, made by local artisans.',
    price: 79.99,
    discountedPrice: 64,
    image: 'https://www.moroccancorridor.com/cdn/shop/products/hamza-pendant-zaina-moroccan-jewelry-moroccan-corridorr-517.jpg?v=1623867915',
    categoryId: '6', // Jewelry
    colors: ['Silver'],
    sizes: [],
    isFavorite: false,
  ),
  ProductEntity(
    id: '7',
    title: 'Handwoven Basket',
    description: 'Colorful basket made from palm leaves, perfect for home storage or decoration.',
    price: 24.99,
    discountedPrice: 19,
    image: 'https://www.ikea.com/ma/en/images/products/hoekrubba-basket-with-lid-bamboo__1376758_pe960491_s5.jpg',
    categoryId: '2', // Crafts
    colors: ['Natural', 'Multi'],
    sizes: ['Small', 'Medium'],
    isFavorite: true,
  ),
  ProductEntity(
    id: '8',
    title: 'Tadelakt Candle Holder',
    description: 'Polished stone-like candle holder made from traditional Tadelakt plaster, adding a rustic touch.',
    price: 34.99,
    discountedPrice: 29,
    image: 'https://cdn.myonlinestore.eu/9438a284-6be1-11e9-a722-44a8421b9960/image/cache/full/6f3bfc6d2d61155c70e820d99b88ae9241990835.jpg',
    categoryId: '3', // Pottery
    colors: ['Gray', 'Beige'],
    sizes: [],
    isFavorite: false,
  ),
];


  static List<ProductEntity> getProducts() {
    return products;
  }

  static List<CategoryEntity> getCategories() {
    return categories;
  }

  static List<ProductEntity> getProductsByCategory(String categoryId) {
    return products.where((product) => product.categoryId == categoryId).toList();
  }

  static ProductEntity? getProductById(String id) {
    try {
      return products.firstWhere((product) => product.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<CartItemEntity> getCartItems() {
    return _cartItems;
  }

  static void addToCart(String productId, int quantity, String color, String size) {
    final product = getProductById(productId);
    if (product == null) return;

    // Check if item already exists in cart
    final existingItemIndex = _cartItems.indexWhere((item) => 
        item.product.id == productId && 
        item.selectedColor == color && 
        item.selectedSize == size);

    if (existingItemIndex != -1) {
      // Update quantity
      _cartItems[existingItemIndex] = CartItemEntity(
        id: _cartItems[existingItemIndex].id,
        product: product,
        quantity: _cartItems[existingItemIndex].quantity + quantity,
        selectedColor: color,
        selectedSize: size,
      );
    } else {
      // Add new item
      _cartItems.add(CartItemEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
        quantity: quantity,
        selectedColor: color,
        selectedSize: size,
      ));
    }
  }

  static void removeFromCart(String itemId) {
    _cartItems.removeWhere((item) => item.id == itemId);
  }

  static void updateCartItemQuantity(String itemId, int quantity) {
    final itemIndex = _cartItems.indexWhere((item) => item.id == itemId);
    if (itemIndex != -1) {
      if (quantity <= 0) {
        _cartItems.removeAt(itemIndex);
      } else {
        _cartItems[itemIndex] = CartItemEntity(
          id: _cartItems[itemIndex].id,
          product: _cartItems[itemIndex].product,
          quantity: quantity,
          selectedColor: _cartItems[itemIndex].selectedColor,
          selectedSize: _cartItems[itemIndex].selectedSize,
        );
      }
    }
  }

  static void clearCart() {
    _cartItems.clear();
  }
}