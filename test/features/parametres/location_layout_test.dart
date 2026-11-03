import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/features/parametres/data/localisation_repository.dart';
import 'package:mlc_mobile/features/parametres/presentation/location_settings_screen.dart';
import 'package:mlc_mobile/features/parametres/presentation/settings_providers.dart';
import 'package:mlc_mobile/features/parametres/presentation/terms_screen.dart';

void main() {
  for (final size in const [Size(320, 568), Size(360, 640)]) {
    testWidgets(
      'la page « Ma commune » tient sans débordement sur ${size.width.toInt()} px',
      (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              maLocalisationProvider.overrideWith(
                (ref) async => const MaLocalisation(
                  communeId: 'c-1',
                  communeNom: 'Commune de très long nom pour vérifier le retour à la ligne',
                  regionNom: 'Région de Koulikoro',
                  gpsConsenti: true,
                ),
              ),
            ],
            child: const MaterialApp(home: LocationSettingsScreen()),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ma commune'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('les conditions d’utilisation sont lisibles sans débordement', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 568));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(const MaterialApp(home: TermsScreen()));

    expect(find.text('1. Objet du service'), findsOneWidget);
    expect(find.textContaining('n’est pas encore fourni'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
