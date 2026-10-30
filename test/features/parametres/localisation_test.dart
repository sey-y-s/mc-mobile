import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/features/parametres/data/localisation_repository.dart';

/// Commune de référence : jamais modifiée sans confirmation, aucune coordonnée renvoyée.
void main() {
  test('sans consentement, la détection ne propose rien', () async {
    final repo = MockLocalisationRepository();
    final d = await repo.detecter(12.6, -8.0);
    expect(d.resultat, ResultatDetection.consentementRequis);
    expect((await repo.lire()).suggestion, isNull);
  });

  test('une commune différente devient une proposition, pas un changement', () async {
    final repo = MockLocalisationRepository();
    await repo.consentement(true);
    final avant = await repo.lire();
    final d = await repo.detecter(12.6, -8.0);
    expect(d.resultat, ResultatDetection.suggestionCreee);
    final apres = await repo.lire();
    expect(apres.communeId, avant.communeId, reason: 'la commune de référence ne change pas toute seule');
    expect(apres.suggestion, isNotNull);

    // Une seule proposition en attente.
    final encore = await repo.detecter(12.6, -8.0);
    expect(encore.resultat, ResultatDetection.suggestionEnAttente);
  });

  test('refuser garde la commune ; accepter la remplace', () async {
    final repo = MockLocalisationRepository();
    await repo.consentement(true);
    final d = await repo.detecter(12.6, -8.0);
    final gardee = await repo.refuser(d.suggestion!.id);
    expect(gardee.communeNom, 'Commune I');
    expect(gardee.suggestion, isNull);

    final d2 = await repo.detecter(12.6, -8.0);
    final changee = await repo.accepter(d2.suggestion!.id);
    expect(changee.communeNom, 'Commune III');
    expect(changee.source, SourceLocalisation.gpsConfirmee);
  });

  test('lecture du serveur : source et proposition en attente', () {
    final loc = MaLocalisation.fromJson({
      'communeId': 'c1',
      'communeNom': 'Kati',
      'regionNom': 'Koulikoro',
      'source': 'GPS_CONFIRMEE',
      'gpsConsenti': true,
      'demandeEnAttente': {'id': 's1', 'communeId': 'c2', 'communeNom': 'Kayes Centre', 'regionNom': 'Kayes'},
    });
    expect(loc.libelle, 'Kati, Koulikoro');
    expect(loc.source, SourceLocalisation.gpsConfirmee);
    expect(loc.suggestion!.libelle, 'Kayes Centre (Kayes)');
  });
}
