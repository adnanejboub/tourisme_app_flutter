class CategoryEntity {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final bool? isActive;
  final DateTime? createdDate;
  final DateTime? updatedDate;

  CategoryEntity({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.isActive,
    this.createdDate,
    this.updatedDate,
  });
}