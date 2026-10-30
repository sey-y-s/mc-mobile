import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_models.dart';
import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_repository.dart';

/// Données d'exemple (mode sans serveur).
class MockParcoursValidationRepository implements ParcoursValidationRepository {
  const MockParcoursValidationRepository();

  @override
  Future<ParcoursValidation> get(String citoyenCompetenceId) async =>
      ParcoursValidation(
        citoyenCompetenceId: citoyenCompetenceId,
        competenceNom: 'Compétence',
        statut: StatutParcours.declaree,
        enAttenteEvaluation: false,
        recommandee: ModaliteValidation.documentaire,
        message: 'Parcours recommandé : « Validation documentaire ».',
        modalites: const [
          ModaliteProposee(
            modalite: ModaliteValidation.documentaire,
            libelle: 'Validation documentaire',
            description:
                'Vérification de vos diplômes, certificats ou attestations.',
            disponible: true,
            recommandee: true,
            raison: 'Déposez un justificatif : il sera vérifié.',
            action: 'DEPOSER_PREUVE',
          ),
          ModaliteProposee(
            modalite: ModaliteValidation.pratiqueCentre,
            libelle: 'Évaluation pratique en centre',
            description: 'Examen pratique dans un centre agréé.',
            disponible: false,
            recommandee: false,
            raison: 'Aucun centre agréé dans votre commune ou votre région.',
          ),
        ],
      );

  @override
  Future<void> demanderEvaluation({
    required String citoyenCompetenceId,
    required ModaliteValidation modalite,
    String? centreId,
    String? preuveId,
  }) async {}
}
