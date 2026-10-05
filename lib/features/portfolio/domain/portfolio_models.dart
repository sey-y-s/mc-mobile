// TODO: définir les modèles Dart immuables de la fonctionnalité « portfolio ».
// Contrat provisoire (dossier de référence V3) :
//   PortfolioRealisation(id, titre, description, dateRealisation, lienUrl?, medias: List<MediaRealisation>) ; MediaRealisation(id, type IMAGE|VIDEO|DOCUMENT, url, nomFichier). PAS de classe Portfolio globale.
// Pour chacun : classe `const` avec champs final, factory fromJson(Map<String, dynamic>), enums avec label français
// et fromApi() tolérant (valeur inconnue -> défaut). Pas de génération de code. Modèle à suivre :
// lib/features/competences/domain/citoyen_competence.dart
// Test : test/features/portfolio/portfolio_models_test.dart (fromJson + valeur d'enum inconnue).
