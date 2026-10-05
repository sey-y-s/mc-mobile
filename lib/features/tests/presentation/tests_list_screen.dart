import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Lister les tests disponibles (TestNumeriqueRepository.list) : titre, compétence(s) évaluée(s), durée, dernier score.
//   Un test est une PREUVE, pas une certification officielle : le rappeler dans un texte d'aide.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : PaginatedListView, AppCard, StatusBadge.
// Route : /tests  |  Écran : Tests numériques
class TestsListScreen extends StatelessWidget {
  const TestsListScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Tests numériques");
}
