#!/usr/bin/env python3
"""
Script pour exécuter les tests d'authentification sociale
Usage: python scripts/run_social_auth_tests.py
"""

import subprocess
import sys
import os
from pathlib import Path

def print_header(title):
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")

def print_step(step, description):
    print(f"\n{step}. {description}")
    print("-" * 40)

def run_command(command, description):
    """Exécute une commande et affiche le résultat"""
    print(f"Exécution: {command}")
    try:
        result = subprocess.run(command, shell=True, capture_output=True, text=True)
        if result.returncode == 0:
            print(f"✅ {description} - Succès")
            if result.stdout:
                print(f"Sortie: {result.stdout}")
        else:
            print(f"❌ {description} - Échec")
            if result.stderr:
                print(f"Erreur: {result.stderr}")
        return result.returncode == 0
    except Exception as e:
        print(f"❌ {description} - Erreur: {e}")
        return False

def main():
    print_header("EXÉCUTION DES TESTS - AUTHENTIFICATION SOCIALE")
    
    # Vérifier que nous sommes dans le bon répertoire
    if not Path("pubspec.yaml").exists():
        print("❌ Veuillez exécuter ce script depuis le répertoire racine de l'application Flutter.")
        sys.exit(1)
    
    # Vérifier que Flutter est installé
    if not run_command("flutter --version", "Vérification de Flutter"):
        print("❌ Flutter n'est pas installé ou n'est pas dans le PATH")
        sys.exit(1)
    
    print_step("1", "Installation des dépendances")
    if not run_command("flutter pub get", "Installation des dépendances"):
        print("❌ Échec de l'installation des dépendances")
        sys.exit(1)
    
    print_step("2", "Test des entités")
    if not run_command("flutter test test/social_auth_simple_test.dart", "Test des entités"):
        print("⚠️  Certains tests d'entités ont échoué")
    
    print_step("3", "Test des modèles")
    if not run_command("flutter test test/social_auth_models_test.dart", "Test des modèles"):
        print("⚠️  Certains tests de modèles ont échoué")
    
    print_step("4", "Test des cas d'usage")
    if not run_command("flutter test test/social_auth_usecases_test.dart", "Test des cas d'usage"):
        print("⚠️  Certains tests de cas d'usage ont échoué")
    
    print_step("5", "Test de tous les fichiers de test")
    if not run_command("flutter test test/social_auth_*_test.dart", "Test de tous les fichiers"):
        print("⚠️  Certains tests ont échoué")
    
    print_header("TESTS TERMINÉS")
    print("""
Si tous les tests sont passés, l'authentification sociale est correctement configurée.

Prochaines étapes :
1. Configurez vos clés API selon le guide GUIDE_CONFIGURATION_SOCIAL_AUTH.md
2. Testez l'application : flutter run
3. Vérifiez les logs en cas d'erreur

Pour une configuration automatique :
python scripts/configure_social_auth.py
""")

if __name__ == "__main__":
    main()
