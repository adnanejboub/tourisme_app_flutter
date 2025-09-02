import '../domain/product/entities/product.dart';
import '../domain/category/entities/category.dart';
import '../domain/order/entities/cart_item.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StaticData {
  static List<CartItemEntity> _cartItems = [];

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  static Future<List<ProductEntity>> getProducts() async {
    final url = Uri.parse('http://localhost:8080/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> content = data['content'] ?? [];
      return content.map<ProductEntity>((json) {
        final category = json['category'];
        return ProductEntity(
          id: json['id'].toString(),
          title: json['title'] ?? '',
          description: json['description'] ?? '',
          price: (json['price'] ?? 0).toDouble(),
          discountedPrice: (json['discountedPrice'] ?? 0).toInt(),
          image: json['imageUrl'] ?? '',
          categoryId: category != null ? category['id'].toString() : '',
          colors:
              (json['colors'] as List?)?.map((e) => e.toString()).toList() ??
              [],
          sizes:
              (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
          isFavorite: json['favorite'] ?? false,
          createdDate: json['createdDate'] != null
              ? DateTime.tryParse(json['createdDate'])
              : null,
        );
      }).toList();
    } else {
      throw Exception('Failed to load products');
    }
  }

  static Future<List<CategoryEntity>> getCategories() async {
    final url = Uri.parse('http://localhost:8080/categories');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<CategoryEntity>((json) {
        return CategoryEntity(
          id: json['id'].toString(),
          title: json['title'] ?? '',
          description: json['description'],
          imageUrl: json['imageUrl'],
          isActive: json['isActive'],
          createdDate: json['createdDate'] != null
              ? DateTime.tryParse(json['createdDate'])
              : null,
          updatedDate: json['updatedDate'] != null
              ? DateTime.tryParse(json['updatedDate'])
              : null,
        );
      }).toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  static Future<List<ProductEntity>> getProductsByCategory(
    String categoryId,
  ) async {
    final products = await getProducts();
    return products
        .where((product) => product.categoryId == categoryId)
        .toList();
  }

  static Future<ProductEntity?> getProductById(String id) async {
    final url = Uri.parse('http://localhost:8080/products/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final category = json['category'];
      return ProductEntity(
        id: json['id'].toString(),
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        price: (json['price'] ?? 0).toDouble(),
        discountedPrice: (json['discountedPrice'] ?? 0).toInt(),
        image: json['imageUrl'] ?? '',
        categoryId: category != null ? category['id'].toString() : '',
        colors:
            (json['colors'] as List?)?.map((e) => e.toString()).toList() ?? [],
        sizes:
            (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
        isFavorite: json['favorite'] ?? false,
        createdDate: json['createdDate'] != null
            ? DateTime.tryParse(json['createdDate'])
            : null,
      );
    } else {
      return null;
    }
  }

  static Future<List<CartItemEntity>> getCartItems() async {
    final token = await getToken();

    final url = Uri.parse('http://localhost:8080/cart');
    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map<CartItemEntity>((json) {
        return CartItemEntity(
          id: json['id'].toString(),
          product: ProductEntity(
            id: json['product']['id'].toString(),
            title: json['product']['title'] ?? '',
            description: json['product']['description'] ?? '',
            price: (json['product']['price'] ?? 0).toDouble(),
            discountedPrice: (json['product']['discountedPrice'] ?? 0).toInt(),
            image: json['product']['imageUrl'] ?? '',
            categoryId: json['product']['category']?['id']?.toString() ?? '',
            colors:
                (json['product']['colors'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
            sizes:
                (json['product']['sizes'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [],
            isFavorite: json['product']['favorite'] ?? false,
            createdDate: json['product']['createdDate'] != null
                ? DateTime.tryParse(json['product']['createdDate'])
                : null,
          ),
          quantity: (json['quantity'] ?? 1).toInt(),
          selectedColor: json['selectedColor']?.toString() ?? '',
          selectedSize: json['selectedSize']?.toString() ?? '',
        );
      }).toList();
    } else {
      throw Exception('Failed to load cart items');
    }
  }

  static Future<void> addToCart(
    String productId,
    int quantity,
    String color,
    String size,
  ) async {
    final token = await getToken();
    final url = Uri.parse('http://localhost:8080/cart/add');
    final body = jsonEncode({
      "productId": int.tryParse(productId) ?? productId,
      "quantity": quantity,
      "selectedColor": color,
      "selectedSize": size,
    });
    print("bobody: "+body);
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to add item to cart');
    }
  }

  static Future<void> removeFromCart(String itemId) async {
    final token = await getToken();
    final url = Uri.parse('http://localhost:8080/cart/$itemId');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to remove item from cart');
    }
  }

  static Future<void> updateCartItemQuantity(
    String itemId,
    int quantity,
  ) async {
        final token = await getToken();

    final url = Uri.parse('http://localhost:8080/cart/$itemId');
    final body = jsonEncode({"quantity": quantity});
    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        },
      body: body,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update cart item quantity');
    }
  }

  static Future<void> clearCart() async {
        final token = await getToken();
    final url = Uri.parse('http://localhost:8080/cart/clear');
    final response = await http.delete(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to clear cart');
    }
  }

  static Future<List<ProductEntity>> searchProducts(String query) async {
    final url = Uri.parse('http://localhost:8080/products/search?query=$query');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> content = data['content'] ?? [];
      return content.map<ProductEntity>((json) {
        final category = json['category'];
        return ProductEntity(
          id: json['id'].toString(),
          title: json['title'] ?? '',
          description: json['description'] ?? '',
          price: (json['price'] ?? 0).toDouble(),
          discountedPrice: (json['discountedPrice'] ?? 0).toInt(),
          image: json['imageUrl'] ?? '',
          categoryId: category != null ? category['id'].toString() : '',
          colors:
              (json['colors'] as List?)?.map((e) => e.toString()).toList() ??
              [],
          sizes:
              (json['sizes'] as List?)?.map((e) => e.toString()).toList() ?? [],
          isFavorite: json['favorite'] ?? false,
          createdDate: json['createdDate'] != null
              ? DateTime.tryParse(json['createdDate'])
              : null,
        );
      }).toList();
    } else {
      throw Exception('Failed to search products');
    }
  }
}
