@echo off
echo ============================================================
echo   TEST DE CONFIGURATION - AUTHENTIFICATION SOCIALE
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

echo Test de la configuration de l'authentification sociale...
echo.

REM Exécuter le script Python
python scripts/test_social_auth_config.py

echo.
echo Test termine !
echo.
pause
