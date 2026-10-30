import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/features/contestations/data/contestation_repository.dart';

void main() {
  setUp(MockContestationRepository.resetForTests);

  test('une décision ne peut être contestée qu’une fois tant que l’examen est en cours', () async {
    final repo = MockContestationRepository();
    await repo.creer(objet: ObjetContestation.decision, motif: 'Mon certificat a été mal lu.', validationId: 'v-1');
    expect(
      () => repo.creer(objet: ObjetContestation.decision, motif: 'Encore une fois', validationId: 'v-1'),
      throwsA(isA<StateError>()),
    );
  });

  test('demande de correction du profil : le champ est conservé', () async {
    final repo = MockContestationRepository();
    final c = await repo.creer(objet: ObjetContestation.profil, motif: 'Je m’appelle Awa, pas Ava.', champConcerne: 'prenom');
    expect(c.titre, 'Correction : Mon prénom');
    expect(c.statut, StatutContestation.ouverte);
  });

  test('lecture du serveur', () {
    final c = Contestation.fromJson({
      'id': 'x',
      'typeObjet': 'DECISION_VALIDATION',
      'motif': 'm',
      'statut': 'ACCEPTEE',
      'dateCreation': '2026-10-01T10:00:00',
      'competenceNom': 'Soudure',
      'reponse': 'Nouvelle décision enregistrée.',
    });
    expect(c.titre, 'Décision : Soudure');
    expect(c.statut.enCours, isFalse);
  });
}
