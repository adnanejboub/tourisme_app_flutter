import '../../../../core/services/image_service.dart';

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
  final String? ville;

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
    this.ville,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawId = json['idActivite'] ?? json['id'];
    final int parsedId = rawId is num ? rawId.toInt() : 0;
    final String activityName = json['nom'] as String;
    final String? category = json['categorie']?.toString();
    final String? providedImageUrl = json['imageUrl'] as String? ?? json['image'] as String?;
    
    return ActivityModel(
      id: parsedId,
      nom: activityName,
      description: json['description'] as String?,
      prix: (json['prix'] is num) ? (json['prix'] as num).toDouble() : null,
      imageUrl: providedImageUrl?.isNotEmpty == true 
          ? providedImageUrl 
          : ImageService.getActivityImage(category, activityName),
      dureeMinimun: (json['dureeMinimun'] as num?)?.toInt(),
      dureeMaximun: (json['dureeMaximun'] as num?)?.toInt(),
      saison: json['saison'] as String?,
      niveauDificulta: json['niveauDificulta'] as String?,
      categorie: category,
      ville: json['ville'] as String?,
    );
  }
}


