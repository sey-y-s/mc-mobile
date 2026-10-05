// TODO: définir les modèles Dart immuables de la fonctionnalité « mise_en_relation ».
// Contrat provisoire (dossier de référence V3) :
//   DemandeMiseEnRelation(id, demandeurId, destinataireId, suiviBesoinTalentId?, statut: EN_ATTENTE|ACCEPTEE|REFUSEE, message?, dateDemande, dateReponse?, contact? (présent seulement si ACCEPTEE)).
// Pour chacun : classe `const` avec champs final, factory fromJson(Map<String, dynamic>), enums avec label français
// et fromApi() tolérant (valeur inconnue -> défaut). Pas de génération de code. Modèle à suivre :
// lib/features/competences/domain/citoyen_competence.dart
// Test : test/features/mise_en_relation/mise_en_relation_models_test.dart (fromJson + valeur d'enum inconnue).
