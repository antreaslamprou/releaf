@echo off

echo ===== BUILDING APK =====
call flutter build apk --release
if errorlevel 1 exit /b 1
echo.

echo ===== BUILDING WEB =====
call flutter build web --release
if errorlevel 1 exit /b 1
echo.

echo ===== UPDATING APK =====
copy /Y build\app\outputs\flutter-apk\app-release.apk android-release\app-release.apk
echo.

echo ===== UPDATING WEB FILES =====
rmdir /S /Q web-release\public
mkdir web-release\public
xcopy build\web\* web-release\public\ /E /I /Y
echo.

echo ===== DEPLOYING FIREBASE =====
cd web-release
call firebase deploy