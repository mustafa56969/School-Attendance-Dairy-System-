@echo off
title Building ARM64 APK
echo ========================================
echo School Diary App - ARM64 APK Builder
echo ========================================
echo.
echo Updating dependencies...
call flutter pub get
echo.
echo Building ARM64 APK...
call flutter build apk --target-platform android-arm64 --split-per-abi
echo.
echo Build completed!
echo Check the build\app\outputs\flutter-apk\ directory for the APK file.
echo.
pause