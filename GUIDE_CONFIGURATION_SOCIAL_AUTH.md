# 🔐 Guide de Configuration - Authentification Sociale

Ce guide vous explique étape par étape comment configurer les clés API pour l'authentification sociale (Google, Facebook, Apple) dans votre application.

## 📋 Table des Matières

1. [Configuration Google Sign-In](#1-configuration-google-sign-in)
2. [Configuration Facebook Login](#2-configuration-facebook-login)
3. [Configuration Apple Sign-In](#3-configuration-apple-sign-in)
4. [Configuration Backend](#4-configuration-backend)
5. [Configuration Flutter](#5-configuration-flutter)
6. [Test de l'implémentation](#6-test-de-limplémentation)
7. [Dépannage](#7-dépannage)

---

## 1. Configuration Google Sign-In

### 1.1 Créer un projet Google Cloud

1. **Allez sur [Google Cloud Console](https://console.cloud.google.com/)**
2. **Connectez-vous avec votre compte Google**
3. **Créez un nouveau projet :**
   - Cliquez sur "Sélectionner un projet" en haut
   - Cliquez sur "Nouveau projet"
   - Nom : `Tourisme App Social Auth`
   - Cliquez sur "Créer"

### 1.2 Activer les APIs nécessaires

1. **Dans le menu de navigation, allez dans "APIs & Services" > "Library"**
2. **Recherchez et activez ces APIs :**
   - `Google+ API` (ou `People API`)
   - `Google Sign-In API`
   - `OAuth2 API`

### 1.3 Configurer OAuth 2.0

1. **Allez dans "APIs & Services" > "Credentials"**
2. **Cliquez sur "Create Credentials" > "OAuth 2.0 Client IDs"**
3. **Configurez l'écran de consentement OAuth :**
   - Type d'utilisateur : Externe
   - Nom de l'application : `Tourisme App`
   - Email de support : votre email
   - Email de contact développeur : votre email
   - Domaines autorisés : `localhost` (pour les tests)

4. **Créez les identifiants OAuth 2.0 :**

#### Pour Android :
- **Type d'application :** Android
- **Nom :** `Tourisme App Android`
- **Package name :** `com.tourismeApp.tourisme_app_flutter`
- **SHA-1 certificate fingerprint :** (voir section 1.4)

#### Pour iOS :
- **Type d'application :** iOS
- **Nom :** `Tourisme App iOS`
- **Bundle ID :** `com.tourismeApp.tourisme_app_flutter`

#### Pour Web :
- **Type d'application :** Web application
- **Nom :** `Tourisme App Web`
- **Authorized redirect URIs :** `http://localhost:8080/auth/realms/your_realm/broker/google/endpoint`

### 1.4 Obtenir le SHA-1 fingerprint (Android)

**Pour le debug :**
```bash
cd tourisme_app_flutter
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

**Pour la release :**
```bash
keytool -list -v -keystore path/to/your/release.keystore -alias your_alias
```

### 1.5 Télécharger google-services.json

1. **Allez dans "APIs & Services" > "Credentials"**
2. **Trouvez votre client Android**
3. **Cliquez sur "Télécharger JSON"**
4. **Renommez le fichier en `google-services.json`**
5. **Placez-le dans :** `tourisme_app_flutter/android/app/google-services.json`

---

## 2. Configuration Facebook Login

### 2.1 Créer une application Facebook

1. **Allez sur [Facebook Developers](https://developers.facebook.com/)**
2. **Connectez-vous avec votre compte Facebook**
3. **Cliquez sur "Mes applications" > "Créer une application"**
4. **Sélectionnez "Consommateur"**
5. **Remplissez les informations :**
   - Nom de l'application : `Tourisme App`
   - Email de contact de l'application : votre email
   - Catégorie : `Autre`

### 2.2 Configurer Facebook Login

1. **Dans le tableau de bord de votre application, ajoutez le produit "Facebook Login"**
2. **Sélectionnez "Facebook Login" > "Paramètres"**
3. **Configurez les plateformes :**

#### Pour Android :
- **Package Name :** `com.tourismeApp.tourisme_app_flutter`
- **Class Name :** `com.tourismeApp.tourisme_app_flutter.MainActivity`
- **Key Hash :** (voir section 2.3)

#### Pour iOS :
- **Bundle ID :** `com.tourismeApp.tourisme_app_flutter`

### 2.3 Obtenir le Key Hash (Android)

**Méthode 1 - Via OpenSSL :**
```bash
keytool -exportcert -alias androiddebugkey -keystore ~/.android/debug.keystore | openssl sha1 -binary | openssl base64
```

**Méthode 2 - Via le code Java :**
```java
try {
    PackageInfo info = getPackageManager().getPackageInfo(
            "com.tourismeApp.tourisme_app_flutter",
            PackageManager.GET_SIGNATURES);
    for (Signature signature : info.signatures) {
        MessageDigest md = MessageDigest.getInstance("SHA");
        md.update(signature.toByteArray());
        Log.d("KeyHash:", Base64.encodeToString(md.digest(), Base64.DEFAULT));
    }
} catch (Exception e) {
    Log.e("KeyHash:", e.toString());
}
```

### 2.4 Obtenir les clés API

1. **Allez dans "Paramètres" > "De base"**
2. **Notez :**
   - **App ID** : `VOTRE_FACEBOOK_APP_ID`
   - **App Secret** : `VOTRE_FACEBOOK_APP_SECRET`

---

## 3. Configuration Apple Sign-In

### 3.1 Configurer dans Apple Developer Portal

1. **Allez sur [Apple Developer Portal](https://developer.apple.com/account/)**
2. **Connectez-vous avec votre compte Apple Developer**
3. **Allez dans "Certificates, Identifiers & Profiles"**

### 3.2 Configurer l'App ID

1. **Allez dans "Identifiers" > "App IDs"**
2. **Trouvez votre App ID ou créez-en un :**
   - Description : `Tourisme App`
   - Bundle ID : `com.tourismeApp.tourisme_app_flutter`
3. **Activez "Sign In with Apple"**
4. **Sauvegardez**

### 3.3 Créer un Service ID

1. **Allez dans "Identifiers" > "Services IDs"**
2. **Cliquez sur "+" pour créer un nouveau Service ID**
3. **Remplissez :**
   - Description : `Tourisme App Social Auth`
   - Identifier : `com.tourismeApp.tourisme_app_flutter.social`
4. **Activez "Sign In with Apple"**
5. **Configurez les domaines :**
   - Primary App ID : sélectionnez votre App ID
   - Domains : `localhost` (pour les tests)
   - Return URLs : `http://localhost:8080/auth/realms/your_realm/broker/apple/endpoint`

### 3.4 Créer une clé privée

1. **Allez dans "Keys"**
2. **Cliquez sur "+" pour créer une nouvelle clé**
3. **Remplissez :**
   - Key Name : `Tourisme App Apple Key`
   - Activez "Sign In with Apple"
4. **Téléchargez le fichier .p8**
5. **Notez :**
   - **Key ID** : `VOTRE_APPLE_KEY_ID`
   - **Team ID** : `VOTRE_APPLE_TEAM_ID`

---

## 4. Configuration Backend

### 4.1 Mettre à jour application.properties

Créez ou modifiez le fichier `Tourisme-Back-end/src/main/resources/application-social.properties` :

```properties
# Configuration pour l'authentification sociale

# Google OAuth
google.client.id=VOTRE_GOOGLE_CLIENT_ID
google.client.secret=VOTRE_GOOGLE_CLIENT_SECRET

# Facebook OAuth
facebook.app.id=VOTRE_FACEBOOK_APP_ID
facebook.app.secret=VOTRE_FACEBOOK_APP_SECRET

# Apple OAuth
apple.team.id=VOTRE_APPLE_TEAM_ID
apple.key.id=VOTRE_APPLE_KEY_ID
apple.private.key=VOTRE_APPLE_PRIVATE_KEY

# Configuration Keycloak pour l'authentification sociale
keycloak.social.auth.enabled=true
keycloak.social.providers=google,facebook,apple
```

### 4.2 Configurer Keycloak

1. **Accédez à votre console Keycloak**
2. **Allez dans votre realm > Identity Providers**
3. **Ajoutez les fournisseurs d'identité :**

#### Google :
- **Provider :** Google
- **Client ID :** `VOTRE_GOOGLE_CLIENT_ID`
- **Client Secret :** `VOTRE_GOOGLE_CLIENT_SECRET`

#### Facebook :
- **Provider :** Facebook
- **Client ID :** `VOTRE_FACEBOOK_APP_ID`
- **Client Secret :** `VOTRE_FACEBOOK_APP_SECRET`

#### Apple :
- **Provider :** Apple
- **Client ID :** `com.tourismeApp.tourisme_app_flutter.social`
- **Client Secret :** (généré automatiquement)

---

## 5. Configuration Flutter

### 5.1 Mettre à jour social_auth_config.dart

Modifiez le fichier `tourisme_app_flutter/lib/config/social_auth_config.dart` :

```dart
class SocialAuthConfig {
  // Google Sign-In Configuration
  static const String googleClientId = 'VOTRE_GOOGLE_CLIENT_ID.apps.googleusercontent.com';
  static const String googleWebClientId = 'VOTRE_GOOGLE_WEB_CLIENT_ID.apps.googleusercontent.com';
  
  // Facebook Configuration
  static const String facebookAppId = 'VOTRE_FACEBOOK_APP_ID';
  static const String facebookClientToken = 'VOTRE_FACEBOOK_CLIENT_TOKEN';
  
  // Apple Sign-In Configuration
  static const String appleServiceId = 'com.tourismeApp.tourisme_app_flutter.social';
  static const String appleTeamId = 'VOTRE_APPLE_TEAM_ID';
  static const String appleKeyId = 'VOTRE_APPLE_KEY_ID';
}
```

### 5.2 Mettre à jour google-services.json

Remplacez le contenu du fichier `tourisme_app_flutter/android/app/google-services.json` par votre configuration :

```json
{
  "project_info": {
    "project_number": "VOTRE_PROJECT_NUMBER",
    "project_id": "votre-project-id",
    "storage_bucket": "votre-project-id.appspot.com"
  },
  "client": [
    {
      "client_info": {
        "mobilesdk_app_id": "VOTRE_MOBILE_SDK_APP_ID",
        "android_client_info": {
          "package_name": "com.tourismeApp.tourisme_app_flutter"
        }
      },
      "oauth_client": [
        {
          "client_id": "VOTRE_ANDROID_CLIENT_ID",
          "client_type": 1,
          "android_info": {
            "package_name": "com.tourismeApp.tourisme_app_flutter",
            "certificate_hash": "VOTRE_SHA1_CERTIFICATE_HASH"
          }
        },
        {
          "client_id": "VOTRE_WEB_CLIENT_ID",
          "client_type": 3
        }
      ],
      "api_key": [
        {
          "current_key": "VOTRE_API_KEY"
        }
      ]
    }
  ]
}
```

### 5.3 Mettre à jour Info.plist (iOS)

Modifiez le fichier `tourisme_app_flutter/ios/Runner/Info.plist` :

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key>
    <string>REVERSED_CLIENT_ID</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>VOTRE_REVERSED_CLIENT_ID</string>
    </array>
  </dict>
  <dict>
    <key>CFBundleURLName</key>
    <string>facebook</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>fbVOTRE_FACEBOOK_APP_ID</string>
    </array>
  </dict>
</array>
```

### 5.4 Ajouter les entitlements iOS

Créez le fichier `tourisme_app_flutter/ios/Runner/Runner.entitlements` :

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>
```

---

## 6. Test de l'implémentation

### 6.1 Installer les dépendances

```bash
cd tourisme_app_flutter
flutter pub get
```

### 6.2 Tester l'application

```bash
# Android
flutter run

# iOS
flutter run -d ios
```

### 6.3 Vérifier les logs

**Flutter :**
```bash
flutter logs
```

**Backend :**
```bash
# Dans le répertoire du backend
tail -f logs/application.log
```

---

## 7. Dépannage

### 7.1 Erreurs Google Sign-In

**Problème :** "Sign in failed"
**Solution :**
- Vérifiez le SHA-1 fingerprint
- Vérifiez le package name
- Vérifiez que google-services.json est correct

**Problème :** "Client ID not found"
**Solution :**
- Vérifiez que le client ID est correct
- Vérifiez que l'API est activée

### 7.2 Erreurs Facebook Login

**Problème :** "App not found"
**Solution :**
- Vérifiez l'App ID
- Vérifiez que l'application est en mode développement

**Problème :** "Invalid key hash"
**Solution :**
- Vérifiez le key hash
- Ajoutez le key hash dans la console Facebook

### 7.3 Erreurs Apple Sign-In

**Problème :** "Invalid client"
**Solution :**
- Vérifiez le Service ID
- Vérifiez la configuration des domaines

**Problème :** "Invalid key"
**Solution :**
- Vérifiez la clé privée
- Vérifiez le Key ID et Team ID

### 7.4 Erreurs Backend

**Problème :** "Token validation failed"
**Solution :**
- Vérifiez les clés API
- Vérifiez la configuration Keycloak

**Problème :** "User creation failed"
**Solution :**
- Vérifiez les permissions Keycloak
- Vérifiez la configuration du realm

---

## 📝 Checklist de Configuration

### Google Sign-In
- [ ] Projet Google Cloud créé
- [ ] APIs activées
- [ ] OAuth 2.0 configuré (Android, iOS, Web)
- [ ] SHA-1 fingerprint ajouté
- [ ] google-services.json téléchargé et placé
- [ ] Client ID ajouté dans social_auth_config.dart

### Facebook Login
- [ ] Application Facebook créée
- [ ] Facebook Login ajouté
- [ ] Plateformes configurées (Android, iOS)
- [ ] Key hash ajouté
- [ ] App ID ajouté dans social_auth_config.dart

### Apple Sign-In
- [ ] App ID configuré avec Sign In with Apple
- [ ] Service ID créé
- [ ] Clé privée créée et téléchargée
- [ ] Entitlements iOS ajoutés
- [ ] Service ID ajouté dans social_auth_config.dart

### Backend
- [ ] application-social.properties configuré
- [ ] Fournisseurs d'identité ajoutés dans Keycloak
- [ ] Service SocialAuthService déployé

### Flutter
- [ ] Dépendances installées
- [ ] Configuration mise à jour
- [ ] Tests effectués

---

## 🆘 Support

Si vous rencontrez des problèmes :

1. **Vérifiez les logs** pour identifier l'erreur
2. **Consultez la documentation** des fournisseurs
3. **Testez avec des comptes de test**
4. **Vérifiez la configuration** étape par étape

**Logs utiles :**
- Flutter : `flutter logs`
- Backend : Logs Spring Boot
- Keycloak : Logs d'administration

---

## 🎉 Félicitations !

Une fois toutes les étapes terminées, votre authentification sociale sera fonctionnelle. Les utilisateurs pourront se connecter avec Google, Facebook ou Apple, et seront automatiquement enregistrés dans Keycloak.
