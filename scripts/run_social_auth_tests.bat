@echo off
echo ============================================================
echo   EXECUTION DES TESTS - AUTHENTIFICATION SOCIALE
echo ============================================================
echo.

REM Vérifier que Flutter est installé
flutter --version >nul 2>&1
if errorlevel 1 (
    echo ERREUR: Flutter n'est pas installe ou n'est pas dans le PATH
    echo Veuillez installer Flutter depuis https://flutter.dev
    pause
    exit /b 1
)

REM Vérifier que nous sommes dans le bon répertoire
if not exist "pubspec.yaml" (
    echo ERREUR: Veuillez executer ce script depuis le repertoire racine de l'application Flutter
    pause
    exit /b 1
)

echo Installation des dependances...
flutter pub get

echo.
echo Execution des tests d'authentification sociale...
echo.

echo 1. Test des entites...
flutter test test/social_auth_simple_test.dart

echo.
echo 2. Test des modeles...
flutter test test/social_auth_models_test.dart

echo.
echo 3. Test des cas d'usage...
flutter test test/social_auth_usecases_test.dart

echo.
echo 4. Test de tous les fichiers de test...
flutter test test/social_auth_*_test.dart

echo.
echo ============================================================
echo   TESTS TERMINES
echo ============================================================
echo.
echo Si tous les tests sont passes, l'authentification sociale est correctement configuree.
echo.
pause
