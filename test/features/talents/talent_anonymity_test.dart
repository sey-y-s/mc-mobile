import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/features/talents/domain/talent_models.dart';

void main() {
  test('talent parser keeps profile data anonymous', () {
    final talent = TalentSummary.fromJson({
      'id': 'opaque-profile-1',
      'nom': 'Nom à ignorer',
      'telephone': '+223 70 00 00 00',
      'email': 'person@example.invalid',
      'photoUrl': 'https://example.invalid/person.jpg',
      'regionNom': 'Bamako',
      'disponibilite': 'DISPONIBLE',
      'competences': [
        {'competenceNom': 'Soudure', 'niveau': 'EXPERT'},
      ],
    });

    expect(talent.id, 'opaque-profile-1');
    expect(talent.regionName, 'Bamako');
    expect(talent.skills.single.name, 'Soudure');
    expect(talent.availability.name, 'disponible');
  });

  test('un contact établi garde son nom et sa photo, un inconnu non', () {
    final contact = TalentSummary.fromJson({
      'id': 'p-1',
      'enRelation': true,
      'nomComplet': 'Aminata Traoré',
      'photoUrl': '/api/v1/portfolio-medias/a.png',
      'regionNom': 'Bamako',
    });
    final inconnu = TalentSummary.fromJson({
      'id': 'p-2',
      'enRelation': false,
      'nomComplet': 'Ne doit pas apparaître',
      'photoUrl': '/api/v1/portfolio-medias/b.png',
    });

    expect(contact.relationEtablie, isTrue);
    expect(contact.fullName, 'Aminata Traoré');
    expect(contact.photoUrl, isNotNull);
    expect(inconnu.relationEtablie, isFalse);
    expect(inconnu.fullName, isNull);
    expect(inconnu.photoUrl, isNull);
  });
}
