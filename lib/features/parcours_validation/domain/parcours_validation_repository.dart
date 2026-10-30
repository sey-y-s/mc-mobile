import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_models.dart';

abstract interface class ParcoursValidationRepository {
  /// Parcours de validation recommandé pour une compétence du citoyen connecté.
  Future<ParcoursValidation> get(String citoyenCompetenceId);

  /// Envoie une demande d'évaluation (pratique en centre, portfolio ou maître artisan) au centre choisi.
  Future<void> demanderEvaluation({
    required String citoyenCompetenceId,
    required ModaliteValidation modalite,
    required String centreId,
  });
}
