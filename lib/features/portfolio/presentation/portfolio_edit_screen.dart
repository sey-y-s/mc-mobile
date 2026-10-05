import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Réutiliser PortfolioFormScreen pré-rempli ; permettre d'ajouter/supprimer des médias.

//   COMPOSANTS À RÉUTILISER (ne pas recréer) : FormScaffold.
// Route : /portfolio/:id/modifier  |  Écran : Modifier la réalisation
class PortfolioEditScreen extends StatelessWidget {
  const PortfolioEditScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Modifier la réalisation");
}
