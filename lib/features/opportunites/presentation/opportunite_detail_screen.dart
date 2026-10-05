import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Afficher description complète, type, catégorie, dates ; lien externe éventuel via url_launcher (à ajouter si nécessaire, sinon copier le lien).

//   COMPOSANTS À RÉUTILISER (ne pas recréer) : SectionHeader, InfoRow, StatusBadge.
// Route : /opportunites/:id  |  Écran : Détail opportunité
class OpportuniteDetailScreen extends StatelessWidget {
  const OpportuniteDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Détail opportunité");
}
