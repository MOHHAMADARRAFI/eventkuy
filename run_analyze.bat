@echo off
cd /d "c:\Users\ASUS\EventKuy"
flutter analyze --no-pub > flutter_errors.txt 2>&1
echo Done. Exit code: %ERRORLEVEL% >> flutter_errors.txt
