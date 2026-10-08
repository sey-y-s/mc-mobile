import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/features/admin/presentation/admin_providers.dart';
import 'package:mlc_mobile/features/parametres/presentation/settings_screen.dart';
import 'package:mlc_mobile/features/passport/domain/passport_models.dart';
import 'package:mlc_mobile/features/passport/presentation/passport_providers.dart';

void main() {
  testWidgets('settings page is complete and fits a narrow phone screen',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    const citizen = Citoyen(
      id: 'citizen-1',
      nom: 'Traore',
      prenom: 'Aminata',
      codePasseport: 'MC-2026-123456',
      disponibilite: Disponibilite.disponible,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          currentRoleProvider.overrideWith((ref) async => 'ADMIN'),
          passportProvider.overrideWith((ref) async => citizen),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Aminata Traore'), findsOneWidget);
    expect(find.text('Votre espace'), findsOneWidget);
    expect(find.text('Application'), findsOneWidget);
    expect(find.text('Administration'), findsOneWidget);
    expect(find.text('Se déconnecter'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
