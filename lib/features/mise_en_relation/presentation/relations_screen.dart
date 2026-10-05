import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Deux onglets (TabBar) : Reçues / Envoyées, chacun paginé. Carte : interlocuteur (anonymisé tant que non acceptée), statut, date.
//   Statuts : EN_ATTENTE, ACCEPTEE, REFUSEE. Pull-to-refresh. Empty state par onglet.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : PaginatedListView (un par onglet), AppCard, StatusBadge.
// Route : /relations  |  Écran : Mises en relation
class RelationsScreen extends StatelessWidget {
  const RelationsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Mises en relation");
}
