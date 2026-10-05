// TODO: définir les modèles Dart immuables de la fonctionnalité « opportunites ».
// Contrat provisoire (dossier de référence V3) :
//   Opportunite(id, categorie, titre, description, type: FORMATION_GRATUITE|BOURSE|PROGRAMME|APPEL_CANDIDATURE|CONCOURS|INSERTION|ACCOMPAGNEMENT|AUTRE, statut, datePublication, dateExpiration?). Le mobile ne voit que les PUBLIEE.
// Pour chacun : classe `const` avec champs final, factory fromJson(Map<String, dynamic>), enums avec label français
// et fromApi() tolérant (valeur inconnue -> défaut). Pas de génération de code. Modèle à suivre :
// lib/features/competences/domain/citoyen_competence.dart
// Test : test/features/opportunites/opportunite_models_test.dart (fromJson + valeur d'enum inconnue).
