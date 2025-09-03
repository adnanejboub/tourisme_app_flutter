class CityDto {
  final int id;
  final String nom;
  final String? description;
  final String? imageUrl;

  CityDto({
    required this.id,
    required this.nom,
    this.description,
    this.imageUrl,
  });

  factory CityDto.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['idVille'] ?? json['id'];
    return CityDto(
      id: (idValue as num).toInt(),
      nom: (json['nomVille'] ?? json['nom'] ?? '') as String,
      description: json['description'] as String?,
      imageUrl: (json['imageUrl'] as String?) ?? (json['image'] as String?),
    );
  }
}


