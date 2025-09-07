import '../models/activity.dart';

class ActivityDataService {
  static final List<ActivityModel> _sampleActivities = [
    ActivityModel(
      id: 1,
      nom: "Visite guidée de la Médina de Marrakech",
      description: "Découvrez l'ancienne médina de Marrakech avec un guide local expérimenté. Explorez les souks colorés, la place Jemaa el-Fnaa et les monuments historiques de cette ville impériale.",
      prix: 150.0,
      imageUrl: "https://images.unsplash.com/photo-1539650116574-75c0c6d73c6e?w=800",
      dureeMinimun: 180,
      dureeMaximun: 240,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite guidée",
    ),
    ActivityModel(
      id: 2,
      nom: "Randonnée dans l'Atlas",
      description: "Partez à la découverte des montagnes de l'Atlas avec une randonnée guidée. Admirez les paysages spectaculaires, rencontrez les populations berbères et découvrez leur mode de vie traditionnel.",
      prix: 300.0,
      imageUrl: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
      dureeMinimun: 480,
      dureeMaximun: 600,
      saison: "Printemps, Été, Automne",
      niveauDificulta: "Modéré",
      categorie: "Randonnée",
    ),
    ActivityModel(
      id: 3,
      nom: "Safari dans le désert du Sahara",
      description: "Vivez une expérience inoubliable dans le désert du Sahara. Dormez sous les étoiles dans un campement berbère, faites du dromadaire et admirez le coucher de soleil sur les dunes.",
      prix: 450.0,
      imageUrl: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
      dureeMinimun: 1440,
      dureeMaximun: 2880,
      saison: "Automne, Hiver, Printemps",
      niveauDificulta: "Facile",
      categorie: "Safari",
    ),
    ActivityModel(
      id: 4,
      nom: "Cours de cuisine marocaine",
      description: "Apprenez les secrets de la cuisine marocaine avec un chef local. Préparez des tagines, des couscous et des pâtisseries traditionnelles dans une atmosphère conviviale.",
      prix: 120.0,
      imageUrl: "https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800",
      dureeMinimun: 180,
      dureeMaximun: 240,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Cuisine",
    ),
    ActivityModel(
      id: 5,
      nom: "Surf à Taghazout",
      description: "Surfez sur les vagues de l'Atlantique à Taghazout, l'un des meilleurs spots de surf du Maroc. Cours pour débutants et intermédiaires avec équipement inclus.",
      prix: 200.0,
      imageUrl: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800",
      dureeMinimun: 240,
      dureeMaximun: 360,
      saison: "Toute l'année",
      niveauDificulta: "Modéré",
      categorie: "Sports nautiques",
    ),
    ActivityModel(
      id: 6,
      nom: "Visite des jardins de Majorelle",
      description: "Explorez les magnifiques jardins de Majorelle à Marrakech, créés par le peintre français Jacques Majorelle. Découvrez la collection d'art islamique et les plantes exotiques.",
      prix: 80.0,
      imageUrl: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
      dureeMinimun: 90,
      dureeMaximun: 120,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite culturelle",
    ),
    ActivityModel(
      id: 7,
      nom: "Escalade à Todgha Gorge",
      description: "Affrontez les falaises calcaires de Todgha Gorge, un paradis pour l'escalade. Parfait pour les grimpeurs de tous niveaux avec des voies variées.",
      prix: 250.0,
      imageUrl: "https://images.unsplash.com/photo-1551524164-6cf2ac5313c2?w=800",
      dureeMinimun: 360,
      dureeMaximun: 480,
      saison: "Printemps, Automne",
      niveauDificulta: "Difficile",
      categorie: "Escalade",
    ),
    ActivityModel(
      id: 8,
      nom: "Balade à dos de chameau",
      description: "Profitez d'une balade relaxante à dos de chameau dans le désert. Une expérience authentique pour découvrir les paysages désertiques du Maroc.",
      prix: 100.0,
      imageUrl: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
      dureeMinimun: 60,
      dureeMaximun: 120,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Désert",
    ),
    ActivityModel(
      id: 9,
      nom: "Visite de la mosquée Hassan II",
      description: "Découvrez la magnifique mosquée Hassan II à Casablanca, l'une des plus grandes mosquées du monde. Visite guidée avec explications sur l'architecture islamique.",
      prix: 60.0,
      imageUrl: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
      dureeMinimun: 90,
      dureeMaximun: 120,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite culturelle",
    ),
    ActivityModel(
      id: 10,
      nom: "Rafting sur l'Oued Ahansal",
      description: "Affrontez les rapides de l'Oued Ahansal dans l'Atlas. Une aventure aquatique palpitante avec des paysages à couper le souffle.",
      prix: 180.0,
      imageUrl: "https://images.unsplash.com/photo-1544551763-46a013bb70d5?w=800",
      dureeMinimun: 240,
      dureeMaximun: 300,
      saison: "Printemps, Été",
      niveauDificulta: "Modéré",
      categorie: "Sports nautiques",
    ),
    ActivityModel(
      id: 11,
      nom: "Visite de la tannerie de Fès",
      description: "Explorez les anciennes tanneries de Fès, un site historique unique. Découvrez les techniques traditionnelles de tannage du cuir.",
      prix: 40.0,
      imageUrl: "https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800",
      dureeMinimun: 60,
      dureeMaximun: 90,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite culturelle",
    ),
    ActivityModel(
      id: 12,
      nom: "Parapente à Ifrane",
      description: "Envolez-vous au-dessus des paysages de l'Atlas avec un vol en parapente. Une expérience unique avec vue panoramique sur les montagnes.",
      prix: 350.0,
      imageUrl: "https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800",
      dureeMinimun: 120,
      dureeMaximun: 180,
      saison: "Printemps, Été, Automne",
      niveauDificulta: "Difficile",
      categorie: "Sports aériens",
    ),
  ];

  static List<ActivityModel> getSampleActivities() {
    return List.from(_sampleActivities);
  }

  static List<ActivityModel> getActivitiesByCategory(String category) {
    return _sampleActivities.where((activity) => 
      activity.categorie?.toLowerCase().contains(category.toLowerCase()) == true
    ).toList();
  }

  static List<ActivityModel> getActivitiesBySeason(String season) {
    return _sampleActivities.where((activity) => 
      activity.saison?.toLowerCase().contains(season.toLowerCase()) == true ||
      activity.saison?.toLowerCase() == "toute l'année"
    ).toList();
  }

  static List<ActivityModel> getActivitiesByDifficulty(String difficulty) {
    return _sampleActivities.where((activity) => 
      activity.niveauDificulta?.toLowerCase() == difficulty.toLowerCase()
    ).toList();
  }

  static List<ActivityModel> getActivitiesByPriceRange(double minPrice, double maxPrice) {
    return _sampleActivities.where((activity) => 
      activity.prix != null && 
      activity.prix! >= minPrice && 
      activity.prix! <= maxPrice
    ).toList();
  }

  static ActivityModel? getActivityById(int id) {
    try {
      return _sampleActivities.firstWhere((activity) => activity.id == id);
    } catch (e) {
      return null;
    }
  }

  static List<String> getAvailableCategories() {
    return _sampleActivities
        .map((activity) => activity.categorie ?? '')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList();
  }

  static List<String> getAvailableSeasons() {
    return _sampleActivities
        .map((activity) => activity.saison ?? '')
        .where((season) => season.isNotEmpty)
        .toSet()
        .toList();
  }

  static List<String> getAvailableDifficulties() {
    return _sampleActivities
        .map((activity) => activity.niveauDificulta ?? '')
        .where((difficulty) => difficulty.isNotEmpty)
        .toSet()
        .toList();
  }
}
