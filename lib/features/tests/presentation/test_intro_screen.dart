import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Présenter le test (nombre de questions, durée, règle de réussite) puis bouton « Commencer » -> /tests/:id/question.
//   Charger le test complet UNE fois (questions + propositions) et le garder dans un provider de session de test.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : InfoRow, AppButton, AppCard.
// Route : /tests/:id  |  Écran : Introduction au test
class TestIntroScreen extends StatelessWidget {
  const TestIntroScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Introduction au test");
}
