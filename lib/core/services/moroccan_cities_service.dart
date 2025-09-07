import 'package:flutter/foundation.dart';

class MoroccanCitiesService {
  static final MoroccanCitiesService _instance = MoroccanCitiesService._internal();
  factory MoroccanCitiesService() => _instance;
  MoroccanCitiesService._internal();

  /// Obtenir toutes les villes marocaines
  List<MoroccanCity> getAllCities() {
    return _moroccanCities;
  }

  /// Obtenir une ville par son nom
  MoroccanCity? getCityByName(String name) {
    try {
      return _moroccanCities.firstWhere(
        (city) => city.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  /// Obtenir des villes aléatoirement (exclut la ville sélectionnée)
  List<MoroccanCity> getRandomCities({String? excludeCity, int count = 10}) {
    List<MoroccanCity> cities = List.from(_moroccanCities);
    
    if (excludeCity != null) {
      cities.removeWhere((city) => city.name.toLowerCase() == excludeCity.toLowerCase());
    }
    
    cities.shuffle();
    return cities.take(count).toList();
  }

  /// Obtenir une ville par défaut si aucune n'est trouvée
  MoroccanCity getDefaultCity() {
    return _moroccanCities.first; // Casablanca
  }

  static final List<MoroccanCity> _moroccanCities = [
    MoroccanCity(
      name: 'Casablanca',
      arabicName: 'الدار البيضاء',
      region: 'Casablanca-Settat',
      description: 'Capital économique du Maroc, métropole moderne alliant tradition et innovation. Ville portuaire dynamique avec une architecture Art Déco exceptionnelle.',
      images: [
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'https://images.unsplash.com/photo-1542046522-0bbdcf51abc4?w=800',
        'https://images.unsplash.com/photo-1558391778-3b8e7b3e4c4b?w=800',
      ],
      landmarks: ['Mosquée Hassan II', 'Corniche', 'Morocco Mall', 'Ancienne Médina', 'Place Mohammed V', 'Cathédrale Sacré-Cœur'],
      latitude: 33.5731,
      longitude: -7.5898,
    ),
    MoroccanCity(
      name: 'Marrakech',
      arabicName: 'مراكش',
      region: 'Marrakech-Safi',
      description: 'La ville rouge aux mille couleurs, capitale touristique du Maroc. Ville impériale fascinante où se mêlent souks animés, palais somptueux et jardins luxuriants.',
      images: [
        'https://images.unsplash.com/photo-1517685352821-92cf88aee5a5?w=800',
        'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14?w=800',
        'https://images.unsplash.com/photo-1543731068-7203ae94ea85?w=800',
        'https://images.unsplash.com/photo-1502602898536-47ad22581b52?w=800',
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      ],
      landmarks: ['Jemaa el-Fna', 'Mosquée Koutoubia', 'Jardin Majorelle', 'Bahia Palace', 'Palais El Badi', 'Ménara'],
      latitude: 31.6295,
      longitude: -7.9811,
    ),
    MoroccanCity(
      name: 'Fès',
      arabicName: 'فاس',
      region: 'Fès-Meknès',
      description: 'Ville impériale et spirituelle, berceau de la culture marocaine. Médina millénaire classée UNESCO avec ses ruelles labyrinthiques et son artisanat traditionnel.',
      images: [
        'https://images.unsplash.com/photo-1570191913384-b786dde7d9b4?w=800',
        'https://images.unsplash.com/photo-1613999025406-61b9dd6df0e8?w=800',
        'https://images.unsplash.com/photo-1607437718417-5dc4d4b7e12d?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
        'https://images.unsplash.com/photo-1539186607619-df476afe6ff1?w=800',
      ],
      landmarks: ['Médina de Fès', 'Université Al Quaraouiyine', 'Madrasa Bou Inania', 'Tanneries', 'Palais Royal', 'Borj Nord'],
      latitude: 34.0331,
      longitude: -5.0003,
    ),
    MoroccanCity(
      name: 'Rabat',
      arabicName: 'الرباط',
      region: 'Rabat-Salé-Kénitra',
      description: 'Capitale politique du royaume',
      images: [
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
        'https://images.unsplash.com/photo-1557804506-669a67965ba0?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
      ],
      landmarks: ['Tour Hassan', 'Kasbah des Oudayas', 'Palais Royal', 'Mausolée Mohammed V'],
      latitude: 34.0209,
      longitude: -6.8416,
    ),
    MoroccanCity(
      name: 'Chefchaouen',
      arabicName: 'شفشاون',
      region: 'Tanger-Tétouan-Al Hoceïma',
      description: 'La perle bleue du Maroc',
      images: [
        'https://images.unsplash.com/photo-1520637836862-4d197d17c935?w=800',
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'https://images.unsplash.com/photo-1555718166-6e7b58b5b617?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
      ],
      landmarks: ['Médina bleue', 'Kasbah', 'Grande Mosquée', 'Place Uta el-Hammam'],
      latitude: 35.1688,
      longitude: -5.2636,
    ),
    MoroccanCity(
      name: 'Agadir',
      arabicName: 'أكادير',
      region: 'Souss-Massa',
      description: 'Station balnéaire moderne',
      images: [
        'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800',
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
      ],
      landmarks: ['Plage d\'Agadir', 'Kasbah', 'Souk El Had', 'Marina'],
      latitude: 30.4278,
      longitude: -9.5981,
    ),
    MoroccanCity(
      name: 'Tanger',
      arabicName: 'طنجة',
      region: 'Tanger-Tétouan-Al Hoceïma',
      description: 'Porte de l\'Afrique vers l\'Europe',
      images: [
        'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800',
      ],
      landmarks: ['Grottes d\'Hercule', 'Cap Spartel', 'Kasbah', 'Médina'],
      latitude: 35.7595,
      longitude: -5.8340,
    ),
    MoroccanCity(
      name: 'Essaouira',
      arabicName: 'الصويرة',
      region: 'Marrakech-Safi',
      description: 'Cité des vents alizés',
      images: [
        'https://images.unsplash.com/photo-1591414646028-7b60c18c6f14?w=800',
        'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?w=800',
        'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
      ],
      landmarks: ['Médina fortifiée', 'Port de pêche', 'Plage', 'Remparts'],
      latitude: 31.5125,
      longitude: -9.7737,
    ),
    MoroccanCity(
      name: 'Meknès',
      arabicName: 'مكناس',
      region: 'Fès-Meknès',
      description: 'Ville impériale historique',
      images: [
        'https://images.unsplash.com/photo-1570191913384-b786dde7d9b4?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?w=800',
      ],
      landmarks: ['Bab Mansour', 'Mausolée Moulay Ismail', 'Médina', 'Heri es-Souani'],
      latitude: 33.8935,
      longitude: -5.5473,
    ),
    MoroccanCity(
      name: 'Ouarzazate',
      arabicName: 'ورزازات',
      region: 'Drâa-Tafilalet',
      description: 'Porte du désert',
      images: [
        'https://images.unsplash.com/photo-1509909756405-be0199881695?w=800',
        'https://images.unsplash.com/photo-1544735716-392fe2489ffa?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
      ],
      landmarks: ['Kasbah Taourirt', 'Atlas Studios', 'Ksar Ait Ben Haddou', 'Désert'],
      latitude: 30.9189,
      longitude: -6.8934,
    ),
    MoroccanCity(
      name: 'Tétouan',
      arabicName: 'تطوان',
      region: 'Tanger-Tétouan-Al Hoceïma',
      description: 'La colombe blanche',
      images: [
        'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800',
      ],
      landmarks: ['Médina', 'Musée ethnographique', 'Place Hassan II', 'École des Beaux-Arts'],
      latitude: 35.5889,
      longitude: -5.3626,
    ),
    MoroccanCity(
      name: 'Oujda',
      arabicName: 'وجدة',
      region: 'Oriental',
      description: 'Ville de l\'est marocain',
      images: [
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1577717903315-1691ae25ab3f?w=800',
        'https://images.unsplash.com/photo-1590736969955-71cc94901144?w=800',
      ],
      landmarks: ['Grande Mosquée', 'Médina', 'Parc Lalla Aicha', 'Place du 16 Août'],
      latitude: 34.6814,
      longitude: -1.9086,
    ),
    MoroccanCity(
      name: 'Safi',
      arabicName: 'آسفي',
      region: 'Marrakech-Safi',
      description: 'Port industriel et ville côtière',
      images: [
        'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
        'https://images.unsplash.com/photo-1576013551627-0cc20b96c2a7?w=800',
        'https://images.unsplash.com/photo-1539650116574-75c0c6d0c889?w=800',
        'https://images.unsplash.com/photo-1584464491033-06628f3a6b7b?w=800',
      ],
      landmarks: ['Port de Safi', 'Plage de Safi', 'Médina', 'Poteries'],
      latitude: 32.2994,
      longitude: -9.2372,
    ),
  ];
}

class MoroccanCity {
  final String name;
  final String arabicName;
  final String region;
  final String description;
  final List<String> images;
  final List<String> landmarks;
  final double latitude;
  final double longitude;

  MoroccanCity({
    required this.name,
    required this.arabicName,
    required this.region,
    required this.description,
    required this.images,
    required this.landmarks,
    required this.latitude,
    required this.longitude,
  });

  @override
  String toString() {
    return 'MoroccanCity(name: $name, region: $region)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoroccanCity && other.name == name;
  }

  @override
  int get hashCode => name.hashCode;
}
