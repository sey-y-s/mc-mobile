import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Afficher score, date, réussite/échec, et la preuve générée (ResultatTest -> Preuve) avec lien vers /preuves/:id.
//   Préciser : un résultat de test peut constituer une preuve sans devenir automatiquement une validation.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : AppProgressBar, InfoRow, PreuveTile, StatusBadge.
// Route : /tests/:id/resultat  |  Écran : Résultat du test
class TestResultScreen extends StatelessWidget {
  const TestResultScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Résultat du test");
}
