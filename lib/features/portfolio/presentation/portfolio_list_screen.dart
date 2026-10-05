import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Liste des PortfolioRealisation (titre, date, première image en miniature). Portfolio FACULTATIF : empty state bienveillant.
//   Images : miniatures basse résolution (low-data), chargement différé (cacheWidth, loadingBuilder).
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : PaginatedListView, AppCard.
// Route : /portfolio  |  Écran : Mon portfolio
class PortfolioListScreen extends StatelessWidget {
  const PortfolioListScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Mon portfolio");
}
