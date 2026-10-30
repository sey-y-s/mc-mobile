import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/features/opportunites/data/mock_opportunite_repository.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_models.dart';

void main() {
  late MockOpportuniteRepository repository;

  setUp(() {
    MockOpportuniteRepository.resetForTests();
    repository = const MockOpportuniteRepository();
  });

  group('MockOpportuniteRepository', () {
    test('list returns visible opportunities', () async {
      final items = await repository.list();
      expect(items, isNotEmpty);
      for (final item in items) {
        expect(item.isVisible, isTrue);
      }
    });

    test('list filters by type correctly', () async {
      final formations = await repository.list(
        type: OpportuniteType.formationGratuite,
      );
      expect(formations, isNotEmpty);
      for (final f in formations) {
        expect(f.type, OpportuniteType.formationGratuite);
      }
    });

    test('get returns single item or throws NotFoundFailure', () async {
      final opp = await repository.get('opp-1');
      expect(opp.id, 'opp-1');

      expect(
        () => repository.get('opp-unknown-xyz'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('get throws NetworkFailure on special error id', () async {
      expect(
        () => repository.get('network-error'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  
    test('les opportunités de la commune du citoyen passent en premier', () async {
      final items = await repository.list();
      expect(items.first.proximite, Proximite.commune);
      expect(items.first.localite, isNotNull);
    });

    test('« Près de chez moi » ne garde que la commune ou la région', () async {
      final items = await repository.list(presDeChezMoi: true);
      expect(items, isNotEmpty);
      expect(items.every((o) => o.proximite?.estLocale ?? false), isTrue);
    });

    test('postuler une seule fois, ouvert à tous', () async {
      await repository.postuler('opp-3', message: 'Disponible dès lundi');
      final opp = await repository.get('opp-3');
      expect(opp.dejaPostule, isTrue);
      expect(opp.proximite, Proximite.autre);
      await expectLater(repository.postuler('opp-3'), throwsA(isA<ValidationFailure>()));
    });
  });
}
