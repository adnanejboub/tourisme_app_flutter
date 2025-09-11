import '../models/activity.dart';

class ActivityDataService {
  static final List<ActivityModel> _sampleActivities = [
    // Activités spécifiques à Casablanca (de la page home)
    ActivityModel(
      id: 1001,
      nom: "Shopping à Casablanca",
      description: "Découvrez les centres commerciaux modernes et souks traditionnels de Casablanca. De Morocco Mall aux souks de la médina, explorez la diversité commerciale de la ville.",
      prix: 0.0,
      imageUrl: "assets/images/activities/casablanca_shopping.jpg",
      dureeMinimun: 120,
      dureeMaximun: 300,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "TOURS",
      ville: "Casablanca",
    ),
    ActivityModel(
      id: 1002,
      nom: "Restaurants de Casablanca",
      description: "Savourez la gastronomie marocaine authentique dans les meilleurs restaurants de la ville. De la cuisine traditionnelle aux spécialités modernes.",
      prix: 0.0,
      imageUrl: "assets/images/activities/casablanca_restaurants.jpg",
      dureeMinimun: 90,
      dureeMaximun: 180,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "EVENEMENTS",
      ville: "Casablanca",
    ),
    ActivityModel(
      id: 1003,
      nom: "Vie nocturne à Casablanca",
      description: "Explorez les bars, clubs et cafés de la ville moderne. Découvrez l'ambiance nocturne dynamique de la métropole marocaine.",
      prix: 0.0,
      imageUrl: "assets/images/activities/casablanca_nightlife.jpg",
      dureeMinimun: 180,
      dureeMaximun: 360,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "EVENEMENTS",
      ville: "Casablanca",
    ),
    ActivityModel(
      id: 1006,
      nom: "Galerie d'art de Casablanca",
      description: "Découvrez l'art contemporain marocain et international. Expositions, vernissages et rencontres avec les artistes locaux.",
      prix: 0.0,
      imageUrl: "assets/images/activities/casablanca_art_gallery.jpg",
      dureeMinimun: 90,
      dureeMaximun: 150,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "EVENEMENTS",
      ville: "Casablanca",
    ),
    ActivityModel(
      id: 1007,
      nom: "Business à Casablanca",
      description: "Découvrez le centre d'affaires de Casablanca. Tours modernes, centres de conférences et l'économie dynamique du Maroc.",
      prix: 0.0,
      imageUrl: "assets/images/activities/casablanca_business.jpg",
      dureeMinimun: 120,
      dureeMaximun: 240,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "TOURS",
      ville: "Casablanca",
    ),
    // Monuments de Casablanca (de la page home)
    ActivityModel(
      id: 2001,
      nom: "Mosquée Hassan II",
      description: "L'une des plus grandes mosquées du monde avec un minaret de 200 mètres. Chef-d'œuvre architectural marocain surplombant l'océan Atlantique.",
      prix: 120.0,
      imageUrl: "assets/images/monuments/hassan_ii_mosque.jpg",
      dureeMinimun: 90,
      dureeMaximun: 180,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "MONUMENT",
      ville: "Casablanca",
    ),
    ActivityModel(
      id: 2002,
      nom: "Quartier des Habous",
      description: "Quartier traditionnel avec architecture marocaine authentique. Découvrez les souks, les mosquées et l'artisanat local dans un cadre historique préservé.",
      prix: 0.0,
      imageUrl: "assets/images/monuments/habous_quarter.jpg",
      dureeMinimun: 120,
      dureeMaximun: 240,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "MONUMENT",
      ville: "Casablanca",
    ),
    // Activités supplémentaires de Casablanca
    ActivityModel(
      id: 1005,
      nom: "Shopping à Casablanca",
      description: "Découvrez les centres commerciaux modernes et souks traditionnels de Casablanca.",
      prix: 0.0,
      imageUrl: "assets/images/activities/casablanca_shopping.jpg",
      dureeMinimun: 120,
      dureeMaximun: 300,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Shopping",
      ville: "Casablanca",
    ),
    ActivityModel(
      id: 1008,
      nom: "Galerie d'art de Casablanca",
      description: "Découvrez l'art contemporain marocain et international.",
      prix: 0.0,
      imageUrl: "assets/images/activities/casablanca_art_gallery.jpg",
      dureeMinimun: 90,
      dureeMaximun: 150,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Culture",
      ville: "Casablanca",
    ),
    ActivityModel(
      id: 1009,
      nom: "Business à Casablanca",
      description: "Découvrez le centre d'affaires de Casablanca.",
      prix: 0.0,
      imageUrl: "assets/images/activities/casablanca_business.jpg",
      dureeMinimun: 120,
      dureeMaximun: 240,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite",
      ville: "Casablanca",
    ),
    // Activités spécifiques à Tanger
    ActivityModel(
      id: 1,
      nom: "Visite de la Kasbah de Tanger",
      description: "Explorez la kasbah historique de Tanger avec ses ruelles pittoresques et sa vue panoramique sur le détroit de Gibraltar. Découvrez l'histoire de cette ville portuaire stratégique et admirez l'architecture mauresque. Visite guidée incluant le palais du sultan et les jardins andalous.",
      prix: 80.0,
      imageUrl: "images/activities/kasbah_tanger.jpg",
      dureeMinimun: 120,
      dureeMaximun: 180,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Patrimoine",
      ville: "Tanger",
    ),
    ActivityModel(
      id: 2,
      nom: "Grotte d'Hercule",
      description: "Visitez la légendaire grotte d'Hercule près de Tanger, site mythologique avec vue spectaculaire sur l'océan Atlantique. Découvrez les légendes grecques et l'histoire de ce lieu unique. La grotte offre une ouverture naturelle en forme de carte d'Afrique. Visite guidée avec explications historiques et géologiques.",
      prix: 50.0,
      imageUrl: "images/activities/grotte_hercule.jpg",
      dureeMinimun: 90,
      dureeMaximun: 120,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Nature",
      ville: "Tanger",
    ),
    
    // Activités spécifiques à Fès
    ActivityModel(
      id: 4,
      nom: "Médina de Fès - Visite guidée",
      description: "Explorez la médina historique de Fès, la plus ancienne ville impériale du Maroc et site UNESCO. Découvrez les tanneries, l'artisanat traditionnel et l'architecture millénaire. Visite guidée complète incluant les souks, les fondouks et les monuments historiques. Guide francophone expert en histoire marocaine.",
      prix: 120.0,
      imageUrl: "images/activities/medina_fes.jpg",
      dureeMinimun: 240,
      dureeMaximun: 300,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite culturelle",
      ville: "Fès",
    ),
    ActivityModel(
      id: 5,
      nom: "Tanneries de Fès",
      description: "Visitez les célèbres tanneries de Fès et découvrez les techniques traditionnelles de traitement du cuir datant du 9ème siècle. Observez le travail des artisans dans les cuves colorées et apprenez les secrets du tannage naturel. Visite avec guide spécialisé et explications détaillées du processus artisanal.",
      prix: 40.0,
      imageUrl: "images/activities/tanneries.jpg",
      dureeMinimun: 90,
      dureeMaximun: 120,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Artisanat",
      ville: "Fès",
    ),
    
    // Activités spécifiques à Safi
    ActivityModel(
      id: 8,
      nom: "Plage de Safi et Côte Atlantique",
      description: "Profitez de la magnifique côte atlantique de Safi avec ses plages sauvages et son patrimoine historique. Découvrez la ville portuaire et ses traditions maritimes. Activités nautiques, promenades sur la corniche et découverte de l'histoire maritime de la région. Guide local spécialisé en histoire côtière.",
      prix: 70.0,
      imageUrl: "images/activities/beach_safi.jpg",
      dureeMinimun: 240,
      dureeMaximun: 360,
      saison: "Printemps, Été, Automne",
      niveauDificulta: "Facile",
      categorie: "Plage",
      ville: "Safi",
    ),
    ActivityModel(
      id: 9,
      nom: "Ateliers de Poterie de Safi",
      description: "Découvrez l'art traditionnel de la poterie de Safi, réputée dans tout le Maroc depuis le 16ème siècle. Visitez les ateliers d'artisans et apprenez les techniques ancestrales de céramique. Atelier pratique inclus avec création de votre propre poterie. Guide artisan expert en techniques traditionnelles.",
      prix: 55.0,
      imageUrl: "images/activities/pottery_visit.jpg",
      dureeMinimun: 120,
      dureeMaximun: 180,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Artisanat",
      ville: "Safi",
    ),
    
    // Activités spécifiques à Meknès
    ActivityModel(
      id: 11,
      nom: "Meknès Impérial - Visite complète",
      description: "Découvrez Meknès, ville impériale classée UNESCO avec ses monuments historiques et son architecture grandiose. Explorez l'héritage de Moulay Ismail, le sultan bâtisseur. Visite guidée complète incluant les palais, les jardins et l'histoire de cette capitale impériale. Guide expert en histoire marocaine.",
      prix: 0.0,
      imageUrl: "images/activities/meknes_imperial.jpg",
      dureeMinimun: 180,
      dureeMaximun: 240,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Patrimoine",
      ville: "Meknès",
    ),
    
    // Activités générales du Maroc
    ActivityModel(
      id: 15,
      nom: "Randonnée dans l'Atlas",
      description: "Partez à la découverte des montagnes de l'Atlas avec une randonnée guidée. Admirez les paysages spectaculaires, rencontrez les populations berbères et découvrez leur mode de vie traditionnel.",
      prix: 300.0,
      imageUrl: "images/activities/atlas_hiking.jpg",
      dureeMinimun: 480,
      dureeMaximun: 600,
      saison: "Printemps, Été, Automne",
      niveauDificulta: "Modéré",
      categorie: "Randonnée",
    ),
    ActivityModel(
      id: 16,
      nom: "Safari dans le désert du Sahara",
      description: "Vivez une expérience inoubliable dans le désert du Sahara. Dormez sous les étoiles dans un campement berbère, faites du dromadaire et admirez le coucher de soleil sur les dunes.",
      prix: 450.0,
      imageUrl: "images/activities/desert_tour.jpg",
      dureeMinimun: 1440,
      dureeMaximun: 2880,
      saison: "Automne, Hiver, Printemps",
      niveauDificulta: "Facile",
      categorie: "Safari",
    ),
    ActivityModel(
      id: 17,
      nom: "Visite de la Médina",
      description: "Explorez les médinas historiques du Maroc. Découvrez les souks colorés, l'architecture traditionnelle et l'artisanat local dans ces villes anciennes.",
      prix: 0.0,
      imageUrl: "images/activities/medina_tour.jpg",
      dureeMinimun: 180,
      dureeMaximun: 240,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite culturelle",
    ),
    ActivityModel(
      id: 18,
      nom: "Activités de plage",
      description: "Profitez des magnifiques plages marocaines. Baignade, sports nautiques, détente au soleil et découverte de la culture côtière.",
      prix: 80.0,
      imageUrl: "images/activities/beach_activities.jpg",
      dureeMinimun: 240,
      dureeMaximun: 480,
      saison: "Printemps, Été, Automne",
      niveauDificulta: "Facile",
      categorie: "Plage",
    ),
    ActivityModel(
      id: 19,
      nom: "Patrimoine culturel",
      description: "Découvrez le riche patrimoine culturel du Maroc. Visitez les monuments historiques, les musées et les sites archéologiques.",
      prix: 0.0,
      imageUrl: "images/activities/cultural_heritage.jpg",
      dureeMinimun: 120,
      dureeMaximun: 180,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Culture",
    ),
    ActivityModel(
      id: 20,
      nom: "Visite de Volubilis",
      description: "Explorez les ruines romaines de Volubilis, site archéologique classé au patrimoine mondial de l'UNESCO.",
      prix: 80.0,
      imageUrl: "images/activities/volubilis.jpg",
      dureeMinimun: 120,
      dureeMaximun: 180,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Archéologie",
    ),
    ActivityModel(
      id: 21,
      nom: "Médina de Tétouan",
      description: "Découvrez la médina andalouse de Tétouan, mélange unique d'architecture marocaine et espagnole.",
      prix: 70.0,
      imageUrl: "images/activities/medina_tetouan.jpg",
      dureeMinimun: 120,
      dureeMaximun: 180,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite culturelle",
    ),
    ActivityModel(
      id: 22,
      nom: "Plage de Martil",
      description: "Profitez de la magnifique plage de Martil sur la côte méditerranéenne. Activités nautiques et détente garanties.",
      prix: 50.0,
      imageUrl: "images/activities/beach_martil.jpg",
      dureeMinimun: 240,
      dureeMaximun: 480,
      saison: "Printemps, Été, Automne",
      niveauDificulta: "Facile",
      categorie: "Plage",
    ),
    ActivityModel(
      id: 23,
      nom: "Randonnée dans la forêt de cèdres",
      description: "Marchez dans la majestueuse forêt de cèdres de l'Atlas, habitat des singes magots et paysage unique.",
      prix: 120.0,
      imageUrl: "images/activities/cedar_forest_hiking.jpg",
      dureeMinimun: 180,
      dureeMaximun: 240,
      saison: "Printemps, Été, Automne",
      niveauDificulta: "Modéré",
      categorie: "Randonnée",
    ),
    ActivityModel(
      id: 24,
      nom: "Visite d'Ifrane",
      description: "Découvrez la petite Suisse marocaine. Ifrane offre un climat montagnard et une architecture européenne unique.",
      prix: 90.0,
      imageUrl: "images/activities/ifrane_visit.jpg",
      dureeMinimun: 120,
      dureeMaximun: 180,
      saison: "Toute l'année",
      niveauDificulta: "Facile",
      categorie: "Visite",
    ),
    ActivityModel(
      id: 25,
      nom: "Kitesurf à Dakhla",
      description: "Vivez l'expérience du kitesurf dans la lagune de Dakhla, spot mondialement reconnu pour ce sport nautique.",
      prix: 0.0,
      imageUrl: "images/activities/kitesurf_dakhla.jpg",
      dureeMinimun: 180,
      dureeMaximun: 240,
      saison: "Printemps, Été, Automne",
      niveauDificulta: "Difficile",
      categorie: "Sports nautiques",
    ),
    ActivityModel(
      id: 26,
      nom: "Excursion dans le désert",
      description: "Partez à l'aventure dans le désert marocain. Dromadaires, couchers de soleil et nuit sous les étoiles.",
      prix: 180.0,
      imageUrl: "images/activities/desert_excursion.jpg",
      dureeMinimun: 480,
      dureeMaximun: 720,
      saison: "Automne, Hiver, Printemps",
      niveauDificulta: "Modéré",
      categorie: "Aventure",
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

  static List<ActivityModel> getActivitiesByCity(String cityName) {
    return _sampleActivities.where((activity) => 
      activity.ville?.toLowerCase() == cityName.toLowerCase()
    ).toList();
  }

  static List<ActivityModel> getActivitiesForCity(String cityName) {
    // D'abord, chercher les activités spécifiques à la ville
    final citySpecificActivities = getActivitiesByCity(cityName);
    
    // Si on trouve des activités spécifiques, les retourner
    if (citySpecificActivities.isNotEmpty) {
      return citySpecificActivities;
    }
    
    // Sinon, retourner quelques activités générales
    return _sampleActivities.take(5).toList();
  }

  static List<String> getAvailableCities() {
    return _sampleActivities
        .map((activity) => activity.ville ?? '')
        .where((city) => city.isNotEmpty)
        .toSet()
        .toList();
  }
}