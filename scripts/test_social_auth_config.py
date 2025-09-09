#!/usr/bin/env python3
"""
Script de test pour vérifier la configuration de l'authentification sociale
Usage: python scripts/test_social_auth_config.py
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

def check_file_exists(file_path, description):
    """Vérifie si un fichier existe"""
    if Path(file_path).exists():
        print(f"✅ {description}: {file_path}")
        return True
    else:
        print(f"❌ {description}: {file_path} (MANQUANT)")
        return False

def check_file_content(file_path, required_content, description):
    """Vérifie le contenu d'un fichier"""
    if not Path(file_path).exists():
        print(f"❌ {description}: Fichier non trouvé")
        return False
    
    try:
        content = Path(file_path).read_text(encoding='utf-8')
        if any(keyword in content for keyword in required_content):
            print(f"✅ {description}: Configuration trouvée")
            return True
        else:
            print(f"⚠️  {description}: Configuration incomplète")
            return False
    except Exception as e:
        print(f"❌ {description}: Erreur de lecture - {e}")
        return False

def check_json_file(file_path, required_keys, description):
    """Vérifie un fichier JSON"""
    if not Path(file_path).exists():
        print(f"❌ {description}: Fichier non trouvé")
        return False
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        
        missing_keys = []
        for key in required_keys:
            if not key in str(data):
                missing_keys.append(key)
        
        if missing_keys:
            print(f"⚠️  {description}: Clés manquantes - {missing_keys}")
            return False
        else:
            print(f"✅ {description}: Configuration valide")
            return True
    except Exception as e:
        print(f"❌ {description}: Erreur JSON - {e}")
        return False

def main():
    print_header("TEST DE CONFIGURATION - AUTHENTIFICATION SOCIALE")
    
    # Vérifier que nous sommes dans le bon répertoire
    if not Path("pubspec.yaml").exists():
        print("❌ Veuillez exécuter ce script depuis le répertoire racine de l'application Flutter.")
        sys.exit(1)
    
    print("Vérification de la configuration de l'authentification sociale...")
    
    # Liste des vérifications
    checks = []
    
    # 1. Vérifier les fichiers Flutter
    print_step("1", "Vérification des fichiers Flutter")
    
    checks.append(check_file_exists(
        "lib/config/social_auth_config.dart",
        "Configuration Flutter"
    ))
    
    checks.append(check_file_content(
        "lib/config/social_auth_config.dart",
        ["googleClientId", "facebookAppId", "appleServiceId"],
        "Configuration des clés API"
    ))
    
    # 2. Vérifier la configuration Android
    print_step("2", "Vérification de la configuration Android")
    
    checks.append(check_file_exists(
        "android/app/google-services.json",
        "Google Services JSON"
    ))
    
    checks.append(check_json_file(
        "android/app/google-services.json",
        ["project_info", "client", "oauth_client"],
        "Google Services Configuration"
    ))
    
    checks.append(check_file_exists(
        "android/app/src/main/res/values/strings.xml",
        "Strings Android"
    ))
    
    checks.append(check_file_content(
        "android/app/src/main/res/values/strings.xml",
        ["facebook_app_id", "fb_login_protocol_scheme"],
        "Configuration Facebook Android"
    ))
    
    # 3. Vérifier la configuration iOS
    print_step("3", "Vérification de la configuration iOS")
    
    checks.append(check_file_exists(
        "ios/Runner/Info.plist",
        "Info.plist iOS"
    ))
    
    checks.append(check_file_content(
        "ios/Runner/Info.plist",
        ["CFBundleURLTypes", "CFBundleURLSchemes"],
        "URL Schemes iOS"
    ))
    
    checks.append(check_file_exists(
        "ios/Runner/Runner.entitlements",
        "Entitlements iOS"
    ))
    
    checks.append(check_file_content(
        "ios/Runner/Runner.entitlements",
        ["com.apple.developer.applesignin"],
        "Apple Sign-In Entitlements"
    ))
    
    # 4. Vérifier la configuration Backend
    print_step("4", "Vérification de la configuration Backend")
    
    checks.append(check_file_exists(
        "../Tourisme-Back-end/src/main/resources/application-social.properties",
        "Configuration Backend"
    ))
    
    checks.append(check_file_content(
        "../Tourisme-Back-end/src/main/resources/application-social.properties",
        ["google.client.id", "facebook.app.id", "apple.team.id"],
        "Clés API Backend"
    ))
    
    # 5. Vérifier les dépendances
    print_step("5", "Vérification des dépendances")
    
    checks.append(check_file_content(
        "pubspec.yaml",
        ["google_sign_in", "sign_in_with_apple", "flutter_facebook_auth"],
        "Dépendances Flutter"
    ))
    
    # 6. Résumé
    print_step("6", "Résumé des vérifications")
    
    passed = sum(checks)
    total = len(checks)
    
    print(f"\nVérifications réussies: {passed}/{total}")
    
    if passed == total:
        print_header("✅ CONFIGURATION COMPLÈTE")
        print("""
Toutes les vérifications sont passées ! Votre configuration d'authentification sociale est prête.

Prochaines étapes :
1. Exécutez: flutter pub get
2. Testez l'application: flutter run
3. Vérifiez les logs en cas d'erreur
4. Testez chaque fournisseur d'identité

Si vous rencontrez des problèmes :
- Consultez le guide GUIDE_CONFIGURATION_SOCIAL_AUTH.md
- Vérifiez les logs de l'application
- Testez avec des comptes de test
""")
    else:
        print_header("⚠️  CONFIGURATION INCOMPLÈTE")
        print(f"""
{total - passed} vérification(s) ont échoué. Veuillez corriger les problèmes suivants :

1. Vérifiez que tous les fichiers de configuration existent
2. Vérifiez que les clés API sont correctement configurées
3. Vérifiez que les dépendances sont installées
4. Consultez le guide GUIDE_CONFIGURATION_SOCIAL_AUTH.md

Pour une configuration automatique, exécutez :
python scripts/configure_social_auth.py
""")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
