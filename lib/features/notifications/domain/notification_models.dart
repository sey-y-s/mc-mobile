// TODO: définir les modèles Dart immuables de la fonctionnalité « notifications ».
// Contrat provisoire (dossier de référence V3) :
//   Notification(id, titre, message, type, dateCreation) + état par destinataire NotificationDestinataire(lu, dateReception, dateLecture?).
// Pour chacun : classe `const` avec champs final, factory fromJson(Map<String, dynamic>), enums avec label français
// et fromApi() tolérant (valeur inconnue -> défaut). Pas de génération de code. Modèle à suivre :
// lib/features/competences/domain/citoyen_competence.dart
// Test : test/features/notifications/notification_models_test.dart (fromJson + valeur d'enum inconnue).
