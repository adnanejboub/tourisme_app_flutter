#!/usr/bin/env python3
"""
Script de configuration automatisé pour l'authentification sociale
Usage: python scripts/configure_social_auth.py
"""

import os
import json
import sys
from pathlib import Path

def print_header(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")

def print_step(step, description):
    print(f"\n{step}. {description}")
    print("-" * 40)

def get_user_input(prompt, default=""):
    if default:
        response = input(f"{prompt} [{default}]: ").strip()
        return response if response else default
    else:
        return input(f"{prompt}: ").strip()

def create_social_auth_config():
    """Crée le fichier de configuration social_auth_config.dart"""
    print_step("1", "Configuration des clés API Flutter")
    
    google_client_id = get_user_input("Google Client ID (Android)")
    google_web_client_id = get_user_input("Google Web Client ID")
    facebook_app_id = get_user_input("Facebook App ID")
    facebook_client_token = get_user_input("Facebook Client Token")
    apple_service_id = get_user_input("Apple Service ID", "com.tourismeApp.tourisme_app_flutter.social")
    apple_team_id = get_user_input("Apple Team ID")
    apple_key_id = get_user_input("Apple Key ID")
    
    config_content = f'''/// Configuration pour l'authentification sociale
class SocialAuthConfig {{
  // Google Sign-In Configuration
  static const String googleClientId = '{google_client_id}';
  static const String googleWebClientId = '{google_web_client_id}';
  
  // Facebook Configuration
  static const String facebookAppId = '{facebook_app_id}';
  static const String facebookClientToken = '{facebook_client_token}';
  
  // Apple Sign-In Configuration
  static const String appleServiceId = '{apple_service_id}';
  static const String appleTeamId = '{apple_team_id}';
  static const String appleKeyId = '{apple_key_id}';
  
  // URLs de validation des tokens
  static const String googleTokenValidationUrl = 'https://www.googleapis.com/oauth2/v1/userinfo';
  static const String facebookTokenValidationUrl = 'https://graph.facebook.com/me';
  static const String appleTokenValidationUrl = 'https://appleid.apple.com/auth/keys';
  
  // Configuration des scopes
  static const List<String> googleScopes = ['email', 'profile'];
  static const List<String> facebookPermissions = ['email', 'public_profile'];
  static const List<String> appleScopes = ['email', 'name'];
}}'''
    
    config_path = Path("lib/config/social_auth_config.dart")
    config_path.write_text(config_content, encoding='utf-8')
    print(f"✅ Configuration Flutter créée: {config_path}")

def create_google_services_json():
    """Crée le fichier google-services.json"""
    print_step("2", "Configuration Google Services")
    
    project_number = get_user_input("Google Project Number")
    project_id = get_user_input("Google Project ID")
    mobile_sdk_app_id = get_user_input("Google Mobile SDK App ID")
    android_client_id = get_user_input("Google Android Client ID")
    web_client_id = get_user_input("Google Web Client ID")
    api_key = get_user_input("Google API Key")
    sha1_hash = get_user_input("SHA-1 Certificate Hash")
    
    google_services = {
        "project_info": {
            "project_number": project_number,
            "project_id": project_id,
            "storage_bucket": f"{project_id}.appspot.com"
        },
        "client": [
            {
                "client_info": {
                    "mobilesdk_app_id": mobile_sdk_app_id,
                    "android_client_info": {
                        "package_name": "com.tourismeApp.tourisme_app_flutter"
                    }
                },
                "oauth_client": [
                    {
                        "client_id": android_client_id,
                        "client_type": 1,
                        "android_info": {
                            "package_name": "com.tourismeApp.tourisme_app_flutter",
                            "certificate_hash": sha1_hash
                        }
                    },
                    {
                        "client_id": web_client_id,
                        "client_type": 3
                    }
                ],
                "api_key": [
                    {
                        "current_key": api_key
                    }
                ],
                "services": {
                    "appinvite_service": {
                        "other_platform_oauth_client": [
                            {
                                "client_id": web_client_id,
                                "client_type": 3
                            }
                        ]
                    }
                }
            }
        ],
        "configuration_version": "1"
    }
    
    google_services_path = Path("android/app/google-services.json")
    google_services_path.write_text(json.dumps(google_services, indent=2), encoding='utf-8')
    print(f"✅ Google Services configuré: {google_services_path}")

def create_backend_config():
    """Crée le fichier de configuration backend"""
    print_step("3", "Configuration Backend")
    
    google_client_id = get_user_input("Google Client ID (Backend)")
    google_client_secret = get_user_input("Google Client Secret")
    facebook_app_id = get_user_input("Facebook App ID (Backend)")
    facebook_app_secret = get_user_input("Facebook App Secret")
    apple_team_id = get_user_input("Apple Team ID (Backend)")
    apple_key_id = get_user_input("Apple Key ID (Backend)")
    apple_private_key = get_user_input("Apple Private Key (Backend)")
    
    backend_config = f'''# Configuration pour l'authentification sociale

# Google OAuth
google.client.id={google_client_id}
google.client.secret={google_client_secret}

# Facebook OAuth
facebook.app.id={facebook_app_id}
facebook.app.secret={facebook_app_secret}

# Apple OAuth
apple.team.id={apple_team_id}
apple.key.id={apple_key_id}
apple.private.key={apple_private_key}

# Configuration Keycloak pour l'authentification sociale
keycloak.social.auth.enabled=true
keycloak.social.providers=google,facebook,apple'''
    
    backend_path = Path("../Tourisme-Back-end/src/main/resources/application-social.properties")
    backend_path.write_text(backend_config, encoding='utf-8')
    print(f"✅ Configuration Backend créée: {backend_path}")

def update_ios_info_plist():
    """Met à jour Info.plist pour iOS"""
    print_step("4", "Configuration iOS")
    
    google_reversed_client_id = get_user_input("Google Reversed Client ID")
    facebook_app_id = get_user_input("Facebook App ID (iOS)")
    
    info_plist_path = Path("ios/Runner/Info.plist")
    
    if info_plist_path.exists():
        print(f"⚠️  Veuillez mettre à jour manuellement {info_plist_path}")
        print("Ajoutez ces URL schemes :")
        print(f"Google: {google_reversed_client_id}")
        print(f"Facebook: fb{facebook_app_id}")
    else:
        print(f"❌ Fichier {info_plist_path} non trouvé")

def create_ios_entitlements():
    """Crée le fichier d'entitlements iOS"""
    print_step("5", "Configuration Entitlements iOS")
    
    entitlements_content = '''<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.developer.applesignin</key>
    <array>
        <string>Default</string>
    </array>
</dict>
</plist>'''
    
    entitlements_path = Path("ios/Runner/Runner.entitlements")
    entitlements_path.write_text(entitlements_content, encoding='utf-8')
    print(f"✅ Entitlements iOS créés: {entitlements_path}")

def create_android_strings():
    """Crée le fichier strings.xml pour Android"""
    print_step("6", "Configuration Android Strings")
    
    facebook_app_id = get_user_input("Facebook App ID (Android)")
    
    strings_content = f'''<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="facebook_app_id">{facebook_app_id}</string>
    <string name="fb_login_protocol_scheme">fb{facebook_app_id}</string>
</resources>'''
    
    strings_path = Path("android/app/src/main/res/values/strings.xml")
    strings_path.parent.mkdir(parents=True, exist_ok=True)
    strings_path.write_text(strings_content, encoding='utf-8')
    print(f"✅ Strings Android créés: {strings_path}")

def main():
    print_header("CONFIGURATION AUTOMATISÉE - AUTHENTIFICATION SOCIALE")
    
    print("""
Ce script vous aide à configurer l'authentification sociale pour votre application Flutter.

Avant de commencer, assurez-vous d'avoir :
1. Créé vos projets Google Cloud, Facebook et Apple
2. Obtenu toutes les clés API nécessaires
3. Configuré Keycloak

Appuyez sur Entrée pour continuer...
""")
    
    input()
    
    try:
        # Vérifier que nous sommes dans le bon répertoire
        if not Path("pubspec.yaml").exists():
            print("❌ Veuillez exécuter ce script depuis le répertoire racine de l'application Flutter.")
            sys.exit(1)
        
        # Créer les configurations
        create_social_auth_config()
        create_google_services_json()
        create_backend_config()
        update_ios_info_plist()
        create_ios_entitlements()
        create_android_strings()
        
        print_header("CONFIGURATION TERMINÉE")
        print("""
✅ Configuration automatique terminée !

Prochaines étapes :
1. Vérifiez tous les fichiers créés
2. Testez l'application : flutter run
3. Vérifiez les logs en cas d'erreur
4. Consultez le guide GUIDE_CONFIGURATION_SOCIAL_AUTH.md

Fichiers créés/modifiés :
- lib/config/social_auth_config.dart
- android/app/google-services.json
- ../Tourisme-Back-end/src/main/resources/application-social.properties
- ios/Runner/Runner.entitlements
- android/app/src/main/res/values/strings.xml

N'oubliez pas de :
- Mettre à jour ios/Runner/Info.plist manuellement
- Configurer Keycloak avec vos fournisseurs d'identité
- Tester l'authentification sociale
""")
        
    except KeyboardInterrupt:
        print("\n\n❌ Configuration annulée par l'utilisateur.")
        sys.exit(1)
    except Exception as e:
        print(f"\n❌ Erreur lors de la configuration: {e}")
        sys.exit(1)

if __name__ == "__main__":
    main()
