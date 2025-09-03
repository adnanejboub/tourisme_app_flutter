class ActivityModel {
  final int id;
  final String nom;
  final String? description;
  final double? prix;
  final String? imageUrl;
  final int? dureeMinimun;
  final int? dureeMaximun;

  ActivityModel({
    required this.id,
    required this.nom,
    this.description,
    this.prix,
    this.imageUrl,
    this.dureeMinimun,
    this.dureeMaximun,
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
    );
  }
}


