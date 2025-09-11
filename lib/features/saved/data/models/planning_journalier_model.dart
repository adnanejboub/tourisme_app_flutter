class PlanningJournalierModel {
  final int? idPlanning;
  final DateTime datePlanning;
  final String description;
  final int duree; // en minutes
  final String statut; // 'planifie', 'en_cours', 'termine', 'annule'
  final int? idSejour;

  PlanningJournalierModel({
    this.idPlanning,
    required this.datePlanning,
    required this.description,
    required this.duree,
    required this.statut,
    this.idSejour,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_planning': idPlanning,
      'date_planning': datePlanning.toIso8601String(),
      'description': description,
      'duree': duree,
      'statut': statut,
      'id_sejour': idSejour,
    };
  }

  factory PlanningJournalierModel.fromMap(Map<String, dynamic> map) {
    return PlanningJournalierModel(
      idPlanning: map['id_planning'],
      datePlanning: DateTime.parse(map['date_planning']),
      description: map['description'],
      duree: map['duree'],
      statut: map['statut'],
      idSejour: map['id_sejour'],
    );
  }

  PlanningJournalierModel copyWith({
    int? idPlanning,
    DateTime? datePlanning,
    String? description,
    int? duree,
    String? statut,
    int? idSejour,
  }) {
    return PlanningJournalierModel(
      idPlanning: idPlanning ?? this.idPlanning,
      datePlanning: datePlanning ?? this.datePlanning,
      description: description ?? this.description,
      duree: duree ?? this.duree,
      statut: statut ?? this.statut,
      idSejour: idSejour ?? this.idSejour,
    );
  }
}
