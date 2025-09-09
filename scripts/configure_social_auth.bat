@echo off
echo ============================================================
echo   CONFIGURATION AUTOMATISEE - AUTHENTIFICATION SOCIALE
echo ============================================================
echo.

REM Vérifier que Python est installé
python --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Python n'est pas installe ou n'est pas dans le PATH
    echo Veuillez installer Python depuis https://python.org
    pause
    exit /b 1
)

REM Vérifier que nous sommes dans le bon répertoire
if not exist "pubspec.yaml" (
    echo ERREUR: Veuillez executer ce script depuis le repertoire racine de l'application Flutter
    pause
    exit /b 1
)

echo Configuration de l'authentification sociale...
echo.

REM Exécuter le script Python
python scripts/configure_social_auth.py

echo.
echo Configuration terminee !
echo.
echo Prochaines etapes :
echo 1. Verifiez la configuration: python scripts/test_social_auth_config.py
echo 2. Installez les dependances: flutter pub get
echo 3. Testez l'application: flutter run
echo.
pause
