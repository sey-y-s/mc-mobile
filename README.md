# mlc_mobile

## Démarrage rapide (le backend doit tourner dans IntelliJ, port 8080)

Dans le dossier `mc-mobile`, ouvrez une invite de commandes et tapez :

- `emulateur` : démarre l'émulateur Android (s'il n'est pas lancé) puis l'application.
- `telephone` : se connecte tout seul à votre téléphone en Wi-Fi puis lance l'application.
  La toute première fois, le script vous demande l'adresse et le code d'association affichés sur le téléphone
  (*Options pour les développeurs > Débogage sans fil > Associer l'appareil avec un code*) ; ensuite il retrouve le téléphone seul.
  PC et téléphone doivent être sur le même Wi-Fi.

Un émulateur doit exister (Android Studio > Device Manager > Create Device).


## Lancer l'application sur un téléphone Android connecté sans fil

Pré-requis : le backend tourne sur le PC (IntelliJ, port 8080) et le téléphone est sur le même Wi-Fi que le PC.

1. **Associer le téléphone (une seule fois)** : sur le téléphone, *Options pour les développeurs > Débogage sans fil* > activer,
   puis *Associer l'appareil avec un code d'association*. Sur le PC :
   `adb pair IP:PORT_ASSOCIATION` (saisir le code affiché), puis `adb connect IP:PORT` (port affiché sur l'écran *Débogage sans fil*).
   Android Studio propose aussi *Pair Devices Using Wi-Fi* (QR code).
2. **Lancer l'app** depuis le dossier `mc-mobile` : `scripts\lancer-telephone.bat`
   - Le script crée un tunnel ADB (`adb reverse tcp:8080 tcp:8080`) : l'app appelle `http://127.0.0.1:8080`,
     qui arrive sur le backend du PC. Pas d'adresse IP ni de pare-feu à régler.
   - Variante sans tunnel : `scripts\lancer-telephone.bat -Mode wifi` (utilise l'adresse IP du PC ;
     il faut alors autoriser le port 8080 dans le pare-feu Windows, le script affiche la commande).

Lancement manuel équivalent :

```
adb reverse tcp:8080 tcp:8080
flutter run --dart-define-from-file=config/telephone-adb.json
```

Autres cibles : émulateur Android `config/emulateur.json` (10.0.2.2), navigateur `config/navigateur.json`.
Après une mise à jour des dépendances : `flutter pub get`.

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
