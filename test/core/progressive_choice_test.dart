import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/core/widgets/progressive_choice.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';

void main() {
  Widget host(List<Parcours> options) {
    Parcours? choisi = options.length == 1 ? options.first : null;
    return MaterialApp(
      home: Scaffold(
        body: StatefulBuilder(
          builder: (context, setState) => SingleChildScrollView(
            child: ProgressiveChoice<Parcours>(
              options: options,
              selected: choisi,
              singleNote: Parcours.noteUnique(options),
              titleOf: (p) => p.label,
              detailsOf: (p) => Text('Détails ${p.apiCode}'),
              onChanged: (p) => setState(() => choisi = p),
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('choisir « formel » fait disparaître « informel » et ce qui le concerne', (tester) async {
    await tester.pumpWidget(host(Parcours.values));
    await tester.pumpAndSettle();
    expect(find.text('Secteur formel'), findsOneWidget);
    expect(find.text('Secteur informel'), findsOneWidget);

    await tester.tap(find.text('Secteur formel'));
    await tester.pumpAndSettle();
    expect(find.text('Secteur informel'), findsNothing);
    expect(find.text('Détails FORMEL'), findsOneWidget);
    expect(find.text('Détails INFORMEL'), findsNothing);

    // « Changer » fait revenir les deux options.
    await tester.tap(find.text('Changer'));
    await tester.pumpAndSettle();
    expect(find.text('Secteur informel'), findsOneWidget);
    expect(find.text('Détails FORMEL'), findsNothing);
  });

  testWidgets('un seul secteur possible : imposé, sans choix ni bouton Changer', (tester) async {
    await tester.pumpWidget(host(const [Parcours.formel]));
    await tester.pumpAndSettle();
    expect(find.text('Secteur formel'), findsOneWidget);
    expect(find.text('Secteur informel'), findsNothing);
    expect(find.text('Changer'), findsNothing);
    expect(find.textContaining('seul le secteur formel'), findsOneWidget);
    expect(find.text('Détails FORMEL'), findsOneWidget);
  });
}
