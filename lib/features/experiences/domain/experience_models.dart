// TODO: définir les modèles Dart immuables de la fonctionnalité « experiences ».
// Contrat provisoire (dossier de référence V3) :
//   Experience(id, titre, description, entreprise, dateDebut, dateFin?, enCours, reconversion, competences: List<CitoyenCompetence>). Les compétences mobilisées sont des CitoyenCompetence déjà déclarées.
// Pour chacun : classe `const` avec champs final, factory fromJson(Map<String, dynamic>), enums avec label français
// et fromApi() tolérant (valeur inconnue -> défaut). Pas de génération de code. Modèle à suivre :
// lib/features/competences/domain/citoyen_competence.dart
// Test : test/features/experiences/experience_models_test.dart (fromJson + valeur d'enum inconnue).
