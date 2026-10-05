// TODO: définir les modèles Dart immuables de la fonctionnalité « talents ».
// Contrat provisoire (dossier de référence V3) :
//   TalentSummary(id opaque, competences clés + niveau, communeNom, regionNom, disponibilite, nbValidations, nbPreuves, aPortfolio) ; TalentProfileAnonymized(...) ; TalentFilters(competenceId?, metierId?, regionId?, communeId?, disponibilite?, niveauMin?). AUCUNE donnée de contact.
// Pour chacun : classe `const` avec champs final, factory fromJson(Map<String, dynamic>), enums avec label français
// et fromApi() tolérant (valeur inconnue -> défaut). Pas de génération de code. Modèle à suivre :
// lib/features/competences/domain/citoyen_competence.dart
// Test : test/features/talents/talent_models_test.dart (fromJson + valeur d'enum inconnue).
