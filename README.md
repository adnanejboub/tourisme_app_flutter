# Marhaba Explorer - Application de Tourisme Flutter

Une application de tourisme moderne développée avec Flutter pour découvrir le Maroc et ses merveilles.

## 🌟 Fonctionnalités Principales

### 🌍 Système de Localisation Multilingue
L'application supporte 4 langues :
- 🇺🇸 **Anglais** (English)
- 🇫🇷 **Français** 
- 🇲🇦 **العربية** (Arabe)
- 🇪🇸 **Español** (Espagnol)

#### Comment changer la langue :
1. Allez dans **Profil** → **Préférences**
2. Dans la section **Langue**, sélectionnez votre langue préférée
3. La langue sera automatiquement appliquée à toute l'application
4. Votre choix sera sauvegardé pour les prochaines utilisations

#### Fonctionnalités de localisation :
- ✅ **Persistance** : La langue choisie est sauvegardée localement
- ✅ **Application globale** : Tous les textes de l'application sont traduits
- ✅ **Direction du texte** : Support automatique du RTL pour l'arabe
- ✅ **Interface réactive** : L'interface se met à jour instantanément

### 🏠 Page d'Accueil
- Recommandations personnalisées
- Destinations tendances
- Points forts saisonniers
- Villes en vedette

### 🗺️ Exploration
- Découverte du Maroc
- Recherche de destinations
- Filtres avancés
- Détails des attractions

### 🛍️ Marketplace
- Produits artisanaux marocains
- Panier d'achat
- Processus de commande
- Gestion des catégories

### 👤 Profil Utilisateur
- Gestion du profil
- Préférences personnalisées
- Mode invité
- Système d'authentification

## 🛠️ Technologies Utilisées

- **Flutter** : Framework de développement
- **Provider** : Gestion d'état
- **SharedPreferences** : Stockage local des préférences
- **Material Design 3** : Design moderne et adaptatif

## 📱 Architecture

L'application suit une architecture propre avec :
- **Clean Architecture** : Séparation des couches
- **Provider Pattern** : Gestion d'état réactive
- **Repository Pattern** : Abstraction des données
- **Dependency Injection** : Injection de dépendances

## 🚀 Installation

1. Clonez le repository :
```bash
git clone [url-du-repo]
cd tourisme_app_flutter
```

2. Installez les dépendances :
```bash
flutter pub get
```

3. Lancez l'application :
```bash
flutter run
```

## 📁 Structure du Projet

```
lib/
├── config/           # Configuration (routes, thème)
├── core/            # Logique métier et services
├── data/            # Couche données
├── domain/          # Entités et cas d'usage
├── features/        # Fonctionnalités de l'application
├── shared/          # Widgets et utilitaires partagés
└── main.dart        # Point d'entrée
```

## 🌐 Localisation

### Ajouter une nouvelle langue :

1. **Ajouter la langue dans les constantes** (`lib/core/constants/constants.dart`) :
```dart
static const List<Map<String, String>> supportedLanguages = [
  {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
  {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
  {'code': 'ar', 'name': 'العربية', 'flag': '🇲🇦'},
  {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
  // Ajoutez votre nouvelle langue ici
];
```

2. **Ajouter les traductions** dans `LocalizationService` :
```dart
'VotreLangue': {
  'key': 'Traduction',
  // ... autres traductions
},
```

3. **Mettre à jour les getters** dans `LocalizationService` :
```dart
String get languageCode {
  switch (_currentLanguage) {
    case 'VotreLangue':
      return 'code';
    // ... autres cas
  }
}
```

### Utiliser la localisation dans vos widgets :

```dart
// Avec Consumer
Consumer<LocalizationService>(
  builder: (context, localizationService, child) {
    return Text(localizationService.translate('key'));
  },
)

// Avec LocalizedText widget
LocalizedText('key', style: TextStyle(fontSize: 16))
```

## 🎨 Thèmes

L'application supporte :
- **Thème clair** : Interface lumineuse
- **Thème sombre** : Interface sombre
- **Thème système** : Suit les préférences système

## 📱 Support des Plateformes

- ✅ **Android** : API 21+
- ✅ **iOS** : iOS 12+
- ✅ **Web** : Navigateurs modernes
- ✅ **Desktop** : Windows, macOS, Linux

## 🤝 Contribution

1. Fork le projet
2. Créez une branche pour votre fonctionnalité
3. Committez vos changements
4. Poussez vers la branche
5. Ouvrez une Pull Request

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème :
- Ouvrez une issue sur GitHub
- Contactez l'équipe de développement

---

**Marhaba Explorer** - Découvrez le Maroc comme jamais auparavant ! 🇲🇦✨
