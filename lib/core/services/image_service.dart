class ImageService {
  static const String _basePath = 'images';

  // City images mapping - Focus on Moroccan cities only
  static const Map<String, String> _cityImages = {
    // Major Moroccan cities
    'casablanca': '$_basePath/cities/casablanca.jpg',
    'rabat': '$_basePath/cities/rabat.jpg',
    'marrakech': '$_basePath/cities/marrakech.jpg',
    'fes': '$_basePath/cities/fes.jpg',
    'agadir': '$_basePath/cities/agadir.jpg',
    'tanger': '$_basePath/cities/tanger.jpg',
    'meknes': '$_basePath/cities/meknes.jpg',
    'oujda': '$_basePath/cities/oujda.jpg',
    'tetouan': '$_basePath/cities/tetouan.jpeg',
    'safi': '$_basePath/cities/safi.jpg',
    'ifrane': '$_basePath/cities/ifrane.jpg',
    'dakhla': '$_basePath/cities/dakhla.jpg',

    // Additional Moroccan cities
    'el_jadida': '$_basePath/cities/el_jadida.jpg',
    'kenitra': '$_basePath/cities/kenitra.jpg',
    'nador': '$_basePath/cities/nador.jpg',
    'settat': '$_basePath/cities/settat.jpg',
    'berrechid': '$_basePath/cities/berrechid.jpg',
    'khemisset': '$_basePath/cities/khemisset.jpg',
    'larache': '$_basePath/cities/larache.jpg',
    'khouribga': '$_basePath/cities/khouribga.jpg',
    'beni_mellal': '$_basePath/cities/beni_mellal.jpg',
    'taza': '$_basePath/cities/taza.jpg',
    'er_rachidia': '$_basePath/cities/er_rachidia.jpg',
    'ouarzazate': '$_basePath/cities/ouarzazate.jpg',
    'essaouira': '$_basePath/cities/essaouira.jpg',
    'chefchaouen': '$_basePath/cities/chefchaouen.jpg',
    'asilah': '$_basePath/cities/asilah.jpg',
  };

  // Activity images mapping - Seulement les activités avec images disponibles
  static const Map<String, String> _activityImages = {
    // Activités générales avec images disponibles
    'desert': '$_basePath/activities/desert_tour.jpg',
    'hiking': '$_basePath/activities/atlas_hiking.jpg',
    'medina': '$_basePath/activities/medina_tour.jpg',
    'beach': '$_basePath/activities/beach_activities.jpg',
    'cultural': '$_basePath/activities/cultural_heritage.jpg',
    'tours': '$_basePath/activities/medina_tour.jpg',
    'evenements': '$_basePath/activities/cultural_heritage.jpg',
    'activites_plein_air': '$_basePath/activities/atlas_hiking.jpg',
    'randonnee': '$_basePath/activities/atlas_hiking.jpg',
    'sahara': '$_basePath/activities/desert_tour.jpg',
    'montagne': '$_basePath/activities/atlas_hiking.jpg',
    'plage': '$_basePath/activities/beach_activities.jpg',
    'patrimoine': '$_basePath/activities/cultural_heritage.jpg',
    'souk': '$_basePath/activities/medina_tour.jpg',

    // Activités spécifiques avec images disponibles
    'culture': '$_basePath/activities/cultural_heritage.jpg',
    'poterie': '$_basePath/activities/pottery_visit.jpg',
    'tannerie': '$_basePath/activities/tanneries.jpg',
    'volubilis': '$_basePath/activities/volubilis.jpg',
    'andalouse': '$_basePath/activities/medina_tetouan.jpg',
    'martil': '$_basePath/activities/beach_martil.jpg',
    'kasbah': '$_basePath/activities/kasbah_tanger.jpg',
    'grotte': '$_basePath/activities/grotte_hercule.jpg',
    'cedre': '$_basePath/activities/cedar_forest_hiking.jpg',
    'ifrane': '$_basePath/activities/ifrane_visit.jpg',
    'kitesurf': '$_basePath/activities/kitesurf_dakhla.jpg',
    'excursion': '$_basePath/activities/desert_excursion.jpg',
    'fes': '$_basePath/activities/medina_fes.jpg',
    'meknes': '$_basePath/activities/meknes_imperial.jpg',
    'safi': '$_basePath/activities/beach_safi.jpg',

    // Activités spécifiques avec leurs propres images
    'kasbah_tanger': '$_basePath/activities/kasbah_tanger.jpg',
    'grotte_hercule': '$_basePath/activities/grotte_hercule.jpg',
    'medina_fes': '$_basePath/activities/medina_fes.jpg',
    'tanneries': '$_basePath/activities/tanneries.jpg',
    'beach_safi': '$_basePath/activities/beach_safi.jpg',
    'pottery_visit': '$_basePath/activities/pottery_visit.jpg',
    'meknes_imperial': '$_basePath/activities/meknes_imperial.jpg',
    'atlas_hiking': '$_basePath/activities/atlas_hiking.jpg',
    'desert_tour': '$_basePath/activities/desert_tour.jpg',
    'medina_tour': '$_basePath/activities/medina_tour.jpg',
    'beach_activities': '$_basePath/activities/beach_activities.jpg',
    'cultural_heritage': '$_basePath/activities/cultural_heritage.jpg',
    'medina_tetouan': '$_basePath/activities/medina_tetouan.jpg',
    'beach_martil': '$_basePath/activities/beach_martil.jpg',
    'cedar_forest_hiking': '$_basePath/activities/cedar_forest_hiking.jpg',
    'ifrane_visit': '$_basePath/activities/ifrane_visit.jpg',
    'kitesurf_dakhla': '$_basePath/activities/kitesurf_dakhla.jpg',
    'desert_excursion': '$_basePath/activities/desert_excursion.jpg',
    
    // Casablanca specific activities
    'shopping': '$_basePath/activities/casablanca_shopping.jpg',
    'restaurants': '$_basePath/activities/casablanca_restaurants.jpg',
    'nightlife': '$_basePath/activities/casablanca_nightlife.jpg',
    'vie_nocturne': '$_basePath/activities/casablanca_nightlife.jpg',
    'plage_casablanca': '$_basePath/activities/casablanca_beach.jpg',
    'business': '$_basePath/activities/casablanca_business.jpg',
    'art_gallery': '$_basePath/activities/casablanca_art_gallery.jpg',
    'galerie_art': '$_basePath/activities/casablanca_art_gallery.jpg',
    'casablanca': '$_basePath/activities/casablanca_shopping.jpg',
  };

  // Monument images mapping
  static const Map<String, String> _monumentImages = {
    'hassan_ii': '$_basePath/monuments/hassan_ii_mosque.jpg',
    'mosquee_hassan_ii': '$_basePath/monuments/hassan_ii_mosque.jpg',
    'habous': '$_basePath/monuments/habous_quarter.jpg',
    'quartier_habous': '$_basePath/monuments/habous_quarter.jpg',
  };

  /// Get representative image for a city based on its name
  static String getCityImage(String cityName) {
    final normalizedName = cityName
        .toLowerCase()
        .replaceAll(' ', '_')
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('à', 'a')
        .replaceAll('ç', 'c');

    return _cityImages[normalizedName] ?? _getDefaultCityImage(cityName);
  }

  /// Get representative image for an activity based on its category or name
  static String getActivityImage(String? category, String? activityName) {
    if (activityName != null) {
      final normalizedName = activityName.toLowerCase();

      // Check for specific activity names first (most specific)
      if (normalizedName.contains('kasbah') &&
          normalizedName.contains('tanger')) {
        return _activityImages['kasbah_tanger']!;
      } else if (normalizedName.contains('grotte') &&
          normalizedName.contains('hercule')) {
        return _activityImages['grotte_hercule']!;
      } else if (normalizedName.contains('médina') &&
          normalizedName.contains('fès')) {
        return _activityImages['medina_fes']!;
      } else if (normalizedName.contains('tanneries') &&
          normalizedName.contains('fès')) {
        return _activityImages['tanneries']!;
      } else if (normalizedName.contains('plage') &&
          normalizedName.contains('safi')) {
        return _activityImages['beach_safi']!;
      } else if (normalizedName.contains('poterie') &&
          normalizedName.contains('safi')) {
        return _activityImages['pottery_visit']!;
      } else if (normalizedName.contains('meknès') &&
          normalizedName.contains('impérial')) {
        return _activityImages['meknes_imperial']!;
      } else if (normalizedName.contains('randonnée') &&
          normalizedName.contains('atlas')) {
        return _activityImages['atlas_hiking']!;
      } else if (normalizedName.contains('safari') &&
          normalizedName.contains('désert')) {
        return _activityImages['desert_tour']!;
      } else if (normalizedName.contains('médina') &&
          normalizedName.contains('tétouan')) {
        return _activityImages['medina_tetouan']!;
      } else if (normalizedName.contains('plage') &&
          normalizedName.contains('martil')) {
        return _activityImages['beach_martil']!;
      } else if (normalizedName.contains('forêt') &&
          normalizedName.contains('cèdres')) {
        return _activityImages['cedar_forest_hiking']!;
      } else if (normalizedName.contains('ifrane')) {
        return _activityImages['ifrane_visit']!;
      } else if (normalizedName.contains('kitesurf') &&
          normalizedName.contains('dakhla')) {
        return _activityImages['kitesurf_dakhla']!;
      } else if (normalizedName.contains('excursion') &&
          normalizedName.contains('désert')) {
        return _activityImages['desert_excursion']!;
      } else if (normalizedName.contains('volubilis')) {
        return _activityImages['volubilis']!;
      } else if (normalizedName.contains('shopping') || normalizedName.contains('achat')) {
        return _activityImages['shopping']!;
      } else if (normalizedName.contains('restaurant') || normalizedName.contains('gastronomie')) {
        return _activityImages['restaurants']!;
      } else if (normalizedName.contains('nightlife') || normalizedName.contains('vie_nocturne') || normalizedName.contains('bar')) {
        return _activityImages['nightlife']!;
      } else if (normalizedName.contains('plage') || normalizedName.contains('corniche')) {
        return _activityImages['plage_casablanca']!;
      } else if (normalizedName.contains('business') || normalizedName.contains('commercial')) {
        return _activityImages['business']!;
      } else if (normalizedName.contains('art') || normalizedName.contains('galerie') || normalizedName.contains('culture')) {
        return _activityImages['art_gallery']!;
      } else if (normalizedName.contains('parc') || normalizedName.contains('jardin')) {
        return _activityImages['cultural']!; // Fallback pour les parcs
      }

      // Check for general keywords in activity name
      for (final entry in _activityImages.entries) {
        if (normalizedName.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    if (category != null) {
      final normalizedCategory = category
          .toLowerCase()
          .replaceAll(' ', '_')
          .replaceAll('é', 'e')
          .replaceAll('è', 'e')
          .replaceAll('à', 'a')
          .replaceAll('ç', 'c');

      if (_activityImages.containsKey(normalizedCategory)) {
        return _activityImages[normalizedCategory]!;
      }
    }

    return _getDefaultActivityImage();
  }

  /// Get default city image based on city characteristics
  static String _getDefaultCityImage(String cityName) {
    final name = cityName.toLowerCase();

    // Major Moroccan cities
    if (name.contains('casablanca') || name.contains('casa')) {
      return _cityImages['casablanca']!;
    } else if (name.contains('rabat')) {
      return _cityImages['rabat']!;
    } else if (name.contains('marrakech') || name.contains('marrakech')) {
      return _cityImages['marrakech']!;
    } else if (name.contains('fes') || name.contains('fès')) {
      return _cityImages['fes']!;
    } else if (name.contains('agadir')) {
      return _cityImages['agadir']!;
    } else if (name.contains('tanger') || name.contains('tangier')) {
      return _cityImages['tanger']!;
    } else if (name.contains('meknes') || name.contains('meknès')) {
      return _cityImages['meknes']!;
    } else if (name.contains('oujda')) {
      return _cityImages['oujda']!;
    } else if (name.contains('tetouan') || name.contains('tétouan')) {
      return _cityImages['tetouan']!;
    } else if (name.contains('safi') || name.contains('safí')) {
      return _cityImages['safi']!;
    } else if (name.contains('ifrane')) {
      return _cityImages['ifrane']!;
    } else if (name.contains('dakhla')) {
      return _cityImages['dakhla']!;
    } else if (name.contains('essaouira') || name.contains('mogador')) {
      return _cityImages['essaouira']!;
    } else if (name.contains('chefchaouen') || name.contains('chaouen')) {
      return _cityImages['chefchaouen']!;
    } else if (name.contains('ouarzazate')) {
      return _cityImages['ouarzazate']!;
    } else if (name.contains('er_rachidia') || name.contains('rachidia')) {
      return _cityImages['er_rachidia']!;
    } else if (name.contains('asilah') || name.contains('asila')) {
      return _cityImages['asilah']!;
    } else {
      // Default to Casablanca for unknown cities
      return _cityImages['casablanca']!;
    }
  }

  /// Get default activity image
  static String _getDefaultActivityImage() {
    return _activityImages['cultural']!;
  }

  /// Check if an image URL is a local asset
  static bool isLocalAsset(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) return false;
    return imageUrl.startsWith('images/') || imageUrl.startsWith('assets/');
  }

  /// Get fallback image for cities
  static String getCityFallbackImage() {
    return _cityImages['casablanca']!;
  }

  /// Get fallback image for activities
  static String getActivityFallbackImage() {
    return _activityImages['cultural']!;
  }

  /// Get representative image for a monument based on its name
  static String getMonumentImage(String? monumentName) {
    if (monumentName != null) {
      final normalizedName = monumentName.toLowerCase();

      // Check for specific monument names first (most specific)
      if (normalizedName.contains('hassan') && normalizedName.contains('ii')) {
        return _monumentImages['hassan_ii']!;
      } else if (normalizedName.contains('habous')) {
        return _monumentImages['habous']!;
      }

      // Check for general keywords in monument name
      for (final entry in _monumentImages.entries) {
        if (normalizedName.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    return _getDefaultMonumentImage();
  }

  /// Get default monument image
  static String _getDefaultMonumentImage() {
    return _monumentImages['hassan_ii']!;
  }

  /// Get fallback image for monuments
  static String getMonumentFallbackImage() {
    return _monumentImages['hassan_ii']!;
  }
}
