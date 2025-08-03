import '../../../domain/product/entities/product.dart';

class ProductModel extends ProductEntity {
  ProductModel({
    required super.id,
    required super.title,
    required super.description,
    required super.price,
    required super.image,
    required super.categoryId,
    required super.colors,
    required super.sizes,
    super.isFavorite,
    super.discountedPrice,
    required super.createdDate,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      price: json['price'].toDouble(),
      image: json['image'],
      categoryId: json['categoryId'],
      colors: List<String>.from(json['colors'] ?? []),
      sizes: List<String>.from(json['sizes'] ?? []),
      isFavorite: json['isFavorite'] ?? false,
      discountedPrice: json['discountedPrice'] ?? 0,
      createdDate: DateTime.parse(json['createdDate']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image': image,
      'categoryId': categoryId,
      'colors': colors,
      'sizes': sizes,
      'isFavorite': isFavorite,
      'discountedPrice': discountedPrice,
      'createdDate': createdDate?.toIso8601String(),
    };
  }
}