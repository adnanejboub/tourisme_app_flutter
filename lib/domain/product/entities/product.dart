class ProductEntity {
  final String id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String categoryId;
  final List<String> colors;
  final List<String> sizes;
  final bool isFavorite;
  final int discountedPrice;
  final DateTime ? createdDate;

  ProductEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.categoryId,
    required this.colors,
    required this.sizes,
    this.isFavorite = false,
    this.discountedPrice = 0,
    this.createdDate,
  });
}