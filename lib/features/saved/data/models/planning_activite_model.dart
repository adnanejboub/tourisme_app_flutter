class PlanningActiviteModel {
  final int? idPlanningActivite;
  final int idPlanning;
  final int idActivite;
  final String nomActivite;
  final String description;
  final double prix;
  final int dureeMinimun;
  final int dureeMaximun;
  final String saison;
  final String niveauDificulta;
  final String categorie;
  final String ville;
  final String? imageUrl;
  final DateTime dateActivite;
  final String statut; // 'planifie', 'en_cours', 'termine', 'annule'

  PlanningActiviteModel({
    this.idPlanningActivite,
    required this.idPlanning,
    required this.idActivite,
    required this.nomActivite,
    required this.description,
    required this.prix,
    required this.dureeMinimun,
    required this.dureeMaximun,
    required this.saison,
    required this.niveauDificulta,
    required this.categorie,
    required this.ville,
    this.imageUrl,
    required this.dateActivite,
    required this.statut,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_planning_activite': idPlanningActivite,
      'id_planning': idPlanning,
      'id_activite': idActivite,
      'nom_activite': nomActivite,
      'description': description,
      'prix': prix,
      'duree_minimun': dureeMinimun,
      'duree_maximun': dureeMaximun,
      'saison': saison,
      'niveau_dificulta': niveauDificulta,
      'categorie': categorie,
      'ville': ville,
      'image_url': imageUrl,
      'date_activite': dateActivite.toIso8601String(),
      'statut': statut,
    };
  }

  factory PlanningActiviteModel.fromMap(Map<String, dynamic> map) {
    return PlanningActiviteModel(
      idPlanningActivite: map['id_planning_activite'],
      idPlanning: map['id_planning'],
      idActivite: map['id_activite'],
      nomActivite: map['nom_activite'],
      description: map['description'],
      prix: map['prix']?.toDouble() ?? 0.0,
      dureeMinimun: map['duree_minimun'],
      dureeMaximun: map['duree_maximun'],
      saison: map['saison'],
      niveauDificulta: map['niveau_dificulta'],
      categorie: map['categorie'],
      ville: map['ville'],
      imageUrl: map['image_url'],
      dateActivite: DateTime.parse(map['date_activite']),
      statut: map['statut'],
    );
  }

  PlanningActiviteModel copyWith({
    int? idPlanningActivite,
    int? idPlanning,
    int? idActivite,
    String? nomActivite,
    String? description,
    double? prix,
    int? dureeMinimun,
    int? dureeMaximun,
    String? saison,
    String? niveauDificulta,
    String? categorie,
    String? ville,
    String? imageUrl,
    DateTime? dateActivite,
    String? statut,
  }) {
    return PlanningActiviteModel(
      idPlanningActivite: idPlanningActivite ?? this.idPlanningActivite,
      idPlanning: idPlanning ?? this.idPlanning,
      idActivite: idActivite ?? this.idActivite,
      nomActivite: nomActivite ?? this.nomActivite,
      description: description ?? this.description,
      prix: prix ?? this.prix,
      dureeMinimun: dureeMinimun ?? this.dureeMinimun,
      dureeMaximun: dureeMaximun ?? this.dureeMaximun,
      saison: saison ?? this.saison,
      niveauDificulta: niveauDificulta ?? this.niveauDificulta,
      categorie: categorie ?? this.categorie,
      ville: ville ?? this.ville,
      imageUrl: imageUrl ?? this.imageUrl,
      dateActivite: dateActivite ?? this.dateActivite,
      statut: statut ?? this.statut,
    );
  }
}
