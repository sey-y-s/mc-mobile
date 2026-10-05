// TODO: définir les modèles Dart immuables de la fonctionnalité « tests ».
// Contrat provisoire (dossier de référence V3) :
//   TestNumerique(id, titre, competences, dureeMinutes) ; Question(id, enonce, type: CHOIX_UNIQUE|CHOIX_MULTIPLE|VRAI_FAUX|REPONSE_LIBRE, ordre, points) ; PropositionReponse(id, libelle, ordre) — le champ `correcte` ne doit PAS arriver au client sauf décision backend ; ResultatTest(id, score, datePassage, reussi, preuveId?).
// Pour chacun : classe `const` avec champs final, factory fromJson(Map<String, dynamic>), enums avec label français
// et fromApi() tolérant (valeur inconnue -> défaut). Pas de génération de code. Modèle à suivre :
// lib/features/competences/domain/citoyen_competence.dart
// Test : test/features/tests/test_numerique_models_test.dart (fromJson + valeur d'enum inconnue).
