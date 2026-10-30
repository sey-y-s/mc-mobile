@echo off
rem Lance l'app sur l'emulateur Android. Voir lancer-emulateur.ps1 pour les options.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lancer-emulateur.ps1" %*
