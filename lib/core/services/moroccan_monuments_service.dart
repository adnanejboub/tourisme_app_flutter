class MoroccanMonumentsService {
  static final MoroccanMonumentsService _instance = MoroccanMonumentsService._internal();
  factory MoroccanMonumentsService() => _instance;
  MoroccanMonumentsService._internal();

  // Monuments par ville avec détails complets
  Map<String, List<Map<String, dynamic>>> get monumentsByCity => {
    'Casablanca': [
      {
        'id': 1,
        'nomMonument': 'Mosquée Hassan II',
        'typeMonument': 'Mosquée',
        'description': 'La plus grande mosquée du Maroc et l\'une des plus grandes au monde. Construite sur l\'océan Atlantique, elle est un chef-d\'œuvre architectural moderne.',
        'adresseMonument': 'Boulevard de la Corniche, Casablanca',
        'horairesOuverture': '9h00 - 16h00 (Visites guidées)',
        'prix': 15,
        'gratuit': false,
        'notesMoyennes': 4.9,
        'hasHistorique': 'Élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/casablanca_art_gallery.jpg',
        'latitude': 33.6084,
        'longitude': -7.6328,
        'ville': 'Casablanca',
        'categorie': 'Religieux',
        'periodeConstruction': '1986-1993',
        'architecte': 'Michel Pinseau',
      },
      {
        'id': 2,
        'nomMonument': 'Place Mohammed V',
        'typeMonument': 'Place publique',
        'description': 'Place centrale de Casablanca entourée d\'édifices administratifs de style Art Déco, cœur historique de la ville moderne.',
        'adresseMonument': 'Place Mohammed V, Casablanca',
        'horairesOuverture': '24h/24',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.3,
        'hasHistorique': 'Moyen',
        'hasCulturelle': 'Élevé',
        'imageUrl': 'assets/images/activities/casablanca_business.jpg',
        'latitude': 33.5731,
        'longitude': -7.5898,
        'ville': 'Casablanca',
        'categorie': 'Architectural',
        'periodeConstruction': '1915-1920',
        'architecte': 'Henri Prost',
      },
      {
        'id': 3,
        'nomMonument': 'Marché Central',
        'typeMonument': 'Marché',
        'description': 'Marché traditionnel couvert datant de 1917, témoin de l\'architecture Art Déco de Casablanca.',
        'adresseMonument': 'Rue Mohammed V, Casablanca',
        'horairesOuverture': '6h00 - 20h00',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.2,
        'hasHistorique': 'Moyen',
        'hasCulturelle': 'Élevé',
        'imageUrl': 'assets/images/activities/cultural_heritage.jpg',
        'latitude': 33.5728,
        'longitude': -7.5895,
        'ville': 'Casablanca',
        'categorie': 'Commercial',
        'periodeConstruction': '1917',
        'architecte': 'Inconnu',
      },
    ],
    'Marrakech': [
      {
        'id': 4,
        'nomMonument': 'Place Jemaa el-Fnaa',
        'typeMonument': 'Place publique',
        'description': 'Place emblématique de Marrakech, classée patrimoine mondial de l\'UNESCO. Spectacle vivant de la culture marocaine.',
        'adresseMonument': 'Place Jemaa el-Fnaa, Marrakech',
        'horairesOuverture': '24h/24',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.8,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/medina_tour.jpg',
        'latitude': 31.6258,
        'longitude': -7.9891,
        'ville': 'Marrakech',
        'categorie': 'Culturel',
        'periodeConstruction': 'XIe siècle',
        'architecte': 'Almoravides',
      },
      {
        'id': 5,
        'nomMonument': 'Palais Bahia',
        'typeMonument': 'Palais',
        'description': 'Magnifique palais du XIXe siècle, exemple parfait de l\'architecture marocaine traditionnelle avec ses jardins et cours.',
        'adresseMonument': 'Rue Riad Zitoun el-Jedid, Marrakech',
        'horairesOuverture': '9h00 - 16h30',
        'prix': 10,
        'gratuit': false,
        'notesMoyennes': 4.6,
        'hasHistorique': 'Élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/cultural_heritage.jpg',
        'latitude': 31.6204,
        'longitude': -7.9866,
        'ville': 'Marrakech',
        'categorie': 'Architectural',
        'periodeConstruction': '1859-1873',
        'architecte': 'Si Moussa',
      },
      {
        'id': 6,
        'nomMonument': 'Koutoubia',
        'typeMonument': 'Mosquée',
        'description': 'Mosquée emblématique de Marrakech avec son minaret de 69 mètres, symbole de la ville.',
        'adresseMonument': 'Avenue Mohammed V, Marrakech',
        'horairesOuverture': 'Non accessible aux non-musulmans',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.7,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/medina_tour.jpg',
        'latitude': 31.6244,
        'longitude': -7.9933,
        'ville': 'Marrakech',
        'categorie': 'Religieux',
        'periodeConstruction': '1150-1199',
        'architecte': 'Almohades',
      },
      {
        'id': 7,
        'nomMonument': 'Tombeaux Saadiens',
        'typeMonument': 'Mausolée',
        'description': 'Mausolée royal du XVIe siècle, chef-d\'œuvre de l\'art marocain avec ses décorations en stuc et zellige.',
        'adresseMonument': 'Rue de la Kasbah, Marrakech',
        'horairesOuverture': '9h00 - 16h30',
        'prix': 10,
        'gratuit': false,
        'notesMoyennes': 4.5,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/cultural_heritage.jpg',
        'latitude': 31.6164,
        'longitude': -7.9850,
        'ville': 'Marrakech',
        'categorie': 'Historique',
        'periodeConstruction': '1557-1603',
        'architecte': 'Saadiens',
      },
    ],
    'Fès': [
      {
        'id': 8,
        'nomMonument': 'Médina de Fès',
        'typeMonument': 'Ville historique',
        'description': 'Médina classée patrimoine mondial UNESCO, plus grande zone piétonne du monde, cœur historique de Fès.',
        'adresseMonument': 'Médina de Fès',
        'horairesOuverture': '24h/24',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.9,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/medina_fes.jpg',
        'latitude': 34.0581,
        'longitude': -4.9730,
        'ville': 'Fès',
        'categorie': 'Historique',
        'periodeConstruction': 'IXe siècle',
        'architecte': 'Idrisides',
      },
      {
        'id': 9,
        'nomMonument': 'Université Al Quaraouiyine',
        'typeMonument': 'Université',
        'description': 'Plus ancienne université du monde encore en activité, fondée en 859, centre intellectuel du monde arabe.',
        'adresseMonument': 'Quartier Andalous, Fès',
        'horairesOuverture': '8h00 - 18h00',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.8,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/medina_fes.jpg',
        'latitude': 34.0645,
        'longitude': -4.9738,
        'ville': 'Fès',
        'categorie': 'Éducatif',
        'periodeConstruction': '859',
        'architecte': 'Fatima al-Fihriya',
      },
      {
        'id': 10,
        'nomMonument': 'Tanneries de Chouara',
        'typeMonument': 'Artisanat',
        'description': 'Tanneries traditionnelles du XIe siècle, spectacle unique de la transformation du cuir selon les méthodes ancestrales.',
        'adresseMonument': 'Quartier des Tanneurs, Fès',
        'horairesOuverture': '8h00 - 19h00',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.4,
        'hasHistorique': 'Élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/tanneries.jpg',
        'latitude': 34.0658,
        'longitude': -4.9825,
        'ville': 'Fès',
        'categorie': 'Artisanal',
        'periodeConstruction': 'XIe siècle',
        'architecte': 'Inconnu',
      },
    ],
    'Rabat': [
      {
        'id': 11,
        'nomMonument': 'Tour Hassan',
        'typeMonument': 'Minaret',
        'description': 'Minaret inachevé de la mosquée Hassan, symbole de Rabat et témoin de l\'architecture almohade.',
        'adresseMonument': 'Place de l\'Unité Africaine, Rabat',
        'horairesOuverture': '24h/24',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.6,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/cultural_heritage.jpg',
        'latitude': 34.0249,
        'longitude': -6.8307,
        'ville': 'Rabat',
        'categorie': 'Religieux',
        'periodeConstruction': '1195-1199',
        'architecte': 'Yacoub el-Mansour',
      },
      {
        'id': 12,
        'nomMonument': 'Kasbah des Oudayas',
        'typeMonument': 'Citadelle',
        'description': 'Citadelle historique du XIIe siècle, magnifique vue sur l\'océan et jardins andalous.',
        'adresseMonument': 'Kasbah des Oudayas, Rabat',
        'horairesOuverture': '8h00 - 18h00',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.7,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/kasbah_tanger.jpg',
        'latitude': 34.0308,
        'longitude': -6.8303,
        'ville': 'Rabat',
        'categorie': 'Militaire',
        'periodeConstruction': '1150-1154',
        'architecte': 'Almohades',
      },
      {
        'id': 13,
        'nomMonument': 'Chellah',
        'typeMonument': 'Site archéologique',
        'description': 'Site archéologique romain et médiéval, ruines antiques avec jardin botanique et cigognes.',
        'adresseMonument': 'Chellah, Rabat',
        'horairesOuverture': '8h30 - 17h30',
        'prix': 10,
        'gratuit': false,
        'notesMoyennes': 4.5,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Élevé',
        'imageUrl': 'assets/images/activities/volubilis.jpg',
        'latitude': 34.0139,
        'longitude': -6.8322,
        'ville': 'Rabat',
        'categorie': 'Archéologique',
        'periodeConstruction': 'Ier siècle (romain)',
        'architecte': 'Romains / Mérinides',
      },
    ],
    'Chefchaouen': [
      {
        'id': 14,
        'nomMonument': 'Médina Bleue',
        'typeMonument': 'Ville historique',
        'description': 'Médina aux murs peints en bleu, paysage unique dans les montagnes du Rif, ambiance sereine et photogénique.',
        'adresseMonument': 'Médina de Chefchaouen',
        'horairesOuverture': '24h/24',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.8,
        'hasHistorique': 'Élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/medina_tetouan.jpg',
        'latitude': 35.1716,
        'longitude': -5.2696,
        'ville': 'Chefchaouen',
        'categorie': 'Culturel',
        'periodeConstruction': '1471',
        'architecte': 'Moulay Ali Ben Rachid',
      },
      {
        'id': 15,
        'nomMonument': 'Grande Mosquée',
        'typeMonument': 'Mosquée',
        'description': 'Mosquée principale de Chefchaouen avec son minaret octogonal caractéristique de l\'architecture andalouse.',
        'adresseMonument': 'Place Outa el Hammam, Chefchaouen',
        'horairesOuverture': 'Non accessible aux non-musulmans',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.5,
        'hasHistorique': 'Élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/medina_tetouan.jpg',
        'latitude': 35.1711,
        'longitude': -5.2698,
        'ville': 'Chefchaouen',
        'categorie': 'Religieux',
        'periodeConstruction': '1471',
        'architecte': 'Moulay Ali Ben Rachid',
      },
    ],
    'Tanger': [
      {
        'id': 16,
        'nomMonument': 'Grand Socco',
        'typeMonument': 'Place publique',
        'description': 'Place principale de Tanger, point de rencontre entre l\'Europe et l\'Afrique, ambiance cosmopolite.',
        'adresseMonument': 'Grand Socco, Tanger',
        'horairesOuverture': '24h/24',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.3,
        'hasHistorique': 'Élevé',
        'hasCulturelle': 'Élevé',
        'imageUrl': 'assets/images/activities/kasbah_tanger.jpg',
        'latitude': 35.7888,
        'longitude': -5.8126,
        'ville': 'Tanger',
        'categorie': 'Culturel',
        'periodeConstruction': 'XIXe siècle',
        'architecte': 'Inconnu',
      },
      {
        'id': 17,
        'nomMonument': 'Kasbah de Tanger',
        'typeMonument': 'Citadelle',
        'description': 'Ancienne citadelle avec vue panoramique sur le détroit de Gibraltar, palais du sultan et jardins.',
        'adresseMonument': 'Kasbah de Tanger',
        'horairesOuverture': '9h00 - 16h30',
        'prix': 10,
        'gratuit': false,
        'notesMoyennes': 4.6,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Élevé',
        'imageUrl': 'assets/images/activities/kasbah_tanger.jpg',
        'latitude': 35.7888,
        'longitude': -5.8126,
        'ville': 'Tanger',
        'categorie': 'Militaire',
        'periodeConstruction': 'XVIIe siècle',
        'architecte': 'Inconnu',
      },
    ],
    'Essaouira': [
      {
        'id': 18,
        'nomMonument': 'Médina d\'Essaouira',
        'typeMonument': 'Ville historique',
        'description': 'Médina fortifiée classée UNESCO, architecture portugaise et marocaine, port de pêche traditionnel.',
        'adresseMonument': 'Médina d\'Essaouira',
        'horairesOuverture': '24h/24',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.7,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/beach_activities.jpg',
        'latitude': 31.5085,
        'longitude': -9.7595,
        'ville': 'Essaouira',
        'categorie': 'Historique',
        'periodeConstruction': '1760-1770',
        'architecte': 'Théodore Cornut',
      },
      {
        'id': 19,
        'nomMonument': 'Port de pêche',
        'typeMonument': 'Port',
        'description': 'Port de pêche traditionnel avec ses bateaux bleus, marché aux poissons et ambiance maritime authentique.',
        'adresseMonument': 'Port d\'Essaouira',
        'horairesOuverture': '6h00 - 18h00',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.4,
        'hasHistorique': 'Moyen',
        'hasCulturelle': 'Élevé',
        'imageUrl': 'assets/images/activities/beach_activities.jpg',
        'latitude': 31.5103,
        'longitude': -9.7612,
        'ville': 'Essaouira',
        'categorie': 'Maritime',
        'periodeConstruction': 'XVIIIe siècle',
        'architecte': 'Théodore Cornut',
      },
    ],
    'Meknès': [
      {
        'id': 20,
        'nomMonument': 'Place el-Hedim',
        'typeMonument': 'Place publique',
        'description': 'Place principale de Meknès, ancienne place des destructions, entrée monumentale vers la médina.',
        'adresseMonument': 'Place el-Hedim, Meknès',
        'horairesOuverture': '24h/24',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.2,
        'hasHistorique': 'Élevé',
        'hasCulturelle': 'Élevé',
        'imageUrl': 'assets/images/activities/meknes_imperial.jpg',
        'latitude': 33.8935,
        'longitude': -5.5473,
        'ville': 'Meknès',
        'categorie': 'Culturel',
        'periodeConstruction': 'XVIIe siècle',
        'architecte': 'Moulay Ismail',
      },
      {
        'id': 21,
        'nomMonument': 'Mausolée Moulay Ismail',
        'typeMonument': 'Mausolée',
        'description': 'Tombeau du sultan Moulay Ismail, exemple exceptionnel de l\'art marocain du XVIIe siècle.',
        'adresseMonument': 'Médina de Meknès',
        'horairesOuverture': '9h00 - 12h00, 14h00 - 17h00',
        'prix': 0,
        'gratuit': true,
        'notesMoyennes': 4.6,
        'hasHistorique': 'Très élevé',
        'hasCulturelle': 'Très élevé',
        'imageUrl': 'assets/images/activities/cultural_heritage.jpg',
        'latitude': 33.8935,
        'longitude': -5.5473,
        'ville': 'Meknès',
        'categorie': 'Religieux',
        'periodeConstruction': '1703',
        'architecte': 'Moulay Ismail',
      },
    ],
  };

  // Obtenir tous les monuments
  List<Map<String, dynamic>> getAllMonuments() {
    final List<Map<String, dynamic>> allMonuments = [];
    monumentsByCity.values.forEach((monuments) {
      allMonuments.addAll(monuments);
    });
    return allMonuments;
  }

  // Obtenir les monuments d'une ville spécifique
  List<Map<String, dynamic>> getMonumentsByCity(String cityName) {
    return monumentsByCity[cityName] ?? [];
  }

  // Rechercher des monuments par nom ou description
  List<Map<String, dynamic>> searchMonuments(String query) {
    final queryLower = query.toLowerCase();
    final List<Map<String, dynamic>> results = [];
    
    getAllMonuments().forEach((monument) {
      final name = monument['nomMonument']?.toString().toLowerCase() ?? '';
      final description = monument['description']?.toString().toLowerCase() ?? '';
      final type = monument['typeMonument']?.toString().toLowerCase() ?? '';
      final ville = monument['ville']?.toString().toLowerCase() ?? '';
      final categorie = monument['categorie']?.toString().toLowerCase() ?? '';
      
      if (name.contains(queryLower) ||
          description.contains(queryLower) ||
          type.contains(queryLower) ||
          ville.contains(queryLower) ||
          categorie.contains(queryLower)) {
        results.add(monument);
      }
    });
    
    return results;
  }

  // Obtenir un monument par ID
  Map<String, dynamic>? getMonumentById(int id) {
    final allMonuments = getAllMonuments();
    try {
      return allMonuments.firstWhere((monument) => monument['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Obtenir les monuments par catégorie
  List<Map<String, dynamic>> getMonumentsByCategory(String category) {
    return getAllMonuments()
        .where((monument) => 
            monument['categorie']?.toString().toLowerCase() == category.toLowerCase())
        .toList();
  }

  // Obtenir les monuments historiques
  List<Map<String, dynamic>> getHistoricalMonuments() {
    return getAllMonuments()
        .where((monument) => 
            monument['hasHistorique'] == 'Très élevé' || 
            monument['hasHistorique'] == 'Élevé')
        .toList();
  }

  // Obtenir les monuments culturels
  List<Map<String, dynamic>> getCulturalMonuments() {
    return getAllMonuments()
        .where((monument) => 
            monument['hasCulturelle'] == 'Très élevé' || 
            monument['hasCulturelle'] == 'Élevé')
        .toList();
  }
}
