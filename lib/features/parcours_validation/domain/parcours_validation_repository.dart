import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_models.dart';

abstract interface class ParcoursValidationRepository {
  /// Parcours de validation recommandé pour une compétence du citoyen connecté.
  Future<ParcoursValidation> get(String citoyenCompetenceId);

  /// Envoie une demande d'évaluation : au centre choisi (pratique, portfolio, maître artisan)
  /// ou, pour la validation documentaire, à l'administrateur avec la preuve à examiner ([preuveId]).
  Future<void> demanderEvaluation({
    required String citoyenCompetenceId,
    required ModaliteValidation modalite,
    String? centreId,
    String? preuveId,
  });
}
