class ActivityModel {
  final int id;
  final String nom;
  final String? description;
  final double? prix;
  final String? imageUrl;
  final int? dureeMinimun;
  final int? dureeMaximun;
  final String? saison;
  final String? niveauDificulta;
  final String? categorie;

  ActivityModel({
    required this.id,
    required this.nom,
    this.description,
    this.prix,
    this.imageUrl,
    this.dureeMinimun,
    this.dureeMaximun,
    this.saison,
    this.niveauDificulta,
    this.categorie,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: (json['idActivite'] ?? json['id'] as num).toInt(),
      nom: json['nom'] as String,
      description: json['description'] as String?,
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : null,
      imageUrl: json['imageUrl'] as String? ?? json['image'] as String?,
      dureeMinimun: (json['dureeMinimun'] as num?)?.toInt(),
      dureeMaximun: (json['dureeMaximun'] as num?)?.toInt(),
      saison: json['saison'] as String?,
      niveauDificulta: json['niveauDificulta'] as String?,
      categorie: json['categorie']?.toString(),
    );
  }
}


