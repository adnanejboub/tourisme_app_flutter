class CityDto {
  final int id;
  final String nom;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final String? paysNom;
  final String? climatNom;

  // Characteristics (for filtering)
  final bool? isPlage;
  final bool? isMontagne;
  final bool? isDesert;
  final bool? isRiviera;
  final bool? isHistorique;
  final bool? isCulturelle;
  final bool? isModerne;

  CityDto({
    required this.id,
    required this.nom,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.paysNom,
    this.climatNom,
    this.isPlage,
    this.isMontagne,
    this.isDesert,
    this.isRiviera,
    this.isHistorique,
    this.isCulturelle,
    this.isModerne,
  });

  factory CityDto.fromJson(Map<String, dynamic> json) {
    final dynamic idValue = json['idVille'] ?? json['id'];
    return CityDto(
      id: (idValue as num).toInt(),
      nom: (json['nomVille'] ?? json['nom'] ?? '') as String,
      description: json['description'] as String?,
      imageUrl: (json['imageUrl'] as String?) ?? (json['image'] as String?),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      paysNom: json['paysNom'] as String?,
      climatNom: json['climatNom'] as String?,
      isPlage: json['isPlage'] as bool?,
      isMontagne: json['isMontagne'] as bool?,
      isDesert: json['isDesert'] as bool?,
      isRiviera: json['isRiviera'] as bool?,
      isHistorique: json['isHistorique'] as bool?,
      isCulturelle: json['isCulturelle'] as bool?,
      isModerne: json['isModerne'] as bool?,
    );
  }

  /// Converts this CityDto to a Map<String, dynamic> for use with CityDetailsPage
  Map<String, dynamic> toCityDetailsMap() {
    return {
      'id': id,
      'nomVille': nom,
      'name': nom,
      'description': description ?? '',
      'imageUrl': imageUrl ?? '',
      'image': imageUrl ?? '',
      'latitude': latitude,
      'longitude': longitude,
      'paysNom': paysNom,
      'climatNom': climatNom,
      'isPlage': isPlage,
      'isMontagne': isMontagne,
      'isDesert': isDesert,
      'isRiviera': isRiviera,
      'isHistorique': isHistorique,
      'isCulturelle': isCulturelle,
      'isModerne': isModerne,
    };
  }
}


