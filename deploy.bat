@echo off

echo =====| BUILD APK |=====
call flutter build apk --release
if errorlevel 1 exit /b 1
echo.

echo =====| BUILD WEB |=====
call flutter build web --release
if errorlevel 1 exit /b 1
echo.

echo =====| UPDATE APK |=====
copy /Y build\app\outputs\flutter-apk\app-release.apk android-release\app-release.apk
echo.

echo =====| UPDATE WEB FILES |=====
rmdir /S /Q web-release\public
mkdir web-release\public
echo.

xcopy build\web\* web-release\public\ /E /I /Y

echo =====| DEPLOYING FIREBASE |=====
cd web-release

call firebase deploy