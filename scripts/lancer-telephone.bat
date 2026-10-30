@echo off
rem Lance l'app sur le téléphone Android connecté en Wi-Fi. Voir lancer-telephone.ps1 pour les options.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0lancer-telephone.ps1" %*
