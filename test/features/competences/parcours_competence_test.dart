import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/features/competences/data/mock_competences_repository.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';
import 'package:mlc_mobile/features/competences/domain/competence_ref.dart';
import 'package:mlc_mobile/features/preuves/domain/preuve_models.dart';
import 'package:mlc_mobile/features/validations/data/mock_validation_repository.dart';

void main() {
  setUp(() {
    MockCompetencesRepository.resetForTests();
    MockValidationRepository.resetForTests();
  });

  test('secteur formel : diplôme, certificat, attestation, attestation de stage', () {
    expect(Parcours.formel.preuves, [
      PreuveType.diplome,
      PreuveType.certificat,
      PreuveType.attestation,
      PreuveType.attestationStage,
    ]);
  });

  test("secteur informel : certificat d'un centre professionnel uniquement", () {
    expect(Parcours.informel.preuves, [PreuveType.certificatCentre]);
  });

  test('le secteur est lu depuis le serveur, sinon les anciens types restent proposés', () {
    final base = <String, dynamic>{
      'id': 'cc-9',
      'competenceId': 'c-9',
      'competenceNom': 'Cuisine',
      'niveau': 'DEBUTANT',
      'etat': 'DECLAREE',
      'dateDeclaration': '2026-10-01T10:00:00',
    };
    final informel = CitoyenCompetence.fromJson({...base, 'parcours': 'INFORMEL', 'nombrePreuves': 2});
    expect(informel.parcours, Parcours.informel);
    expect(informel.nombrePreuves, 2);
    expect(informel.preuvesAcceptees, [PreuveType.certificatCentre]);

    final ancienne = CitoyenCompetence.fromJson(base);
    expect(ancienne.parcours, isNull);
    expect(ancienne.preuvesAcceptees, PreuveType.addable);
  });

  test('une compétence ajoutée garde son secteur', () async {
    final created = await const MockCompetencesRepository()
        .add(competenceId: 'c-4', niveau: Niveau.intermediaire, parcours: Parcours.formel);
    expect(created.parcours, Parcours.formel);
    expect(created.etat, EtatCompetence.declaree);
  });

  test('informel sans certificat : demande de test au centre sans preuve', () async {
    final v = await const MockValidationRepository()
        .request(citoyenCompetenceId: 'cc-2', centreId: 'centre-1');
    expect(v.preuveId, isNull);
    expect(v.citoyenCompetenceId, 'cc-2');
  });

  test('hors secteur informel, une preuve reste obligatoire', () async {
    await expectLater(
      const MockValidationRepository().request(citoyenCompetenceId: 'cc-3', centreId: 'centre-1'),
      throwsA(isA<ValidationFailure>()),
    );
  });

  test('le référentiel indique les secteurs possibles (data science : formel uniquement)', () {
    final ref = CompetenceRef.fromJson({'id': 'x', 'nom': 'Science des données', 'parcoursPossibles': ['FORMEL']});
    expect(ref.parcoursPossibles, [Parcours.formel]);
    final ancien = CompetenceRef.fromJson({'id': 'y', 'nom': 'Maçonnerie'});
    expect(ancien.parcoursPossibles, Parcours.values);
    expect(Parcours.noteUnique([Parcours.formel]), contains('formel'));
    expect(Parcours.noteUnique(Parcours.values), isNull);
  });

  test("science des données : le secteur informel est refusé, le formel s'applique d'office", () async {
    const repo = MockCompetencesRepository();
    final refs = await repo.searchReferentiel('donnees');
    expect(refs.first.parcoursPossibles, [Parcours.formel]);
    await expectLater(
      repo.add(competenceId: 'c-13', niveau: Niveau.debutant, parcours: Parcours.informel),
      throwsA(isA<ValidationFailure>()),
    );
    final created = await repo.add(competenceId: 'c-13', niveau: Niveau.debutant);
    expect(created.parcours, Parcours.formel);
    expect(created.preuvesAcceptees, Parcours.formel.preuves);
  });
}
