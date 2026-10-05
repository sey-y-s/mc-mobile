import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Afficher la réalisation et sa galerie de médias (MediaRealisation). Actions modifier/supprimer (confirmDialog).

//   COMPOSANTS À RÉUTILISER (ne pas recréer) : SectionHeader, InfoRow, confirmDialog.
// Route : /portfolio/:id  |  Écran : Détail réalisation
class PortfolioDetailScreen extends StatelessWidget {
  const PortfolioDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Détail réalisation");
}
