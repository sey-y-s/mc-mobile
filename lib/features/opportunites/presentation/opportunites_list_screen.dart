import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Liste paginée des opportunités PUBLIEES non expirées, filtres par type (FORMATION_GRATUITE, BOURSE, PROGRAMME, APPEL_CANDIDATURE, CONCOURS, INSERTION, ACCOMPAGNEMENT, AUTRE) et catégorie.
//   Carte : titre, type (StatusBadge), date d'expiration. Lecture seule : la publication est réservée au SUPER_ADMIN (web).
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : PaginatedListView, FilterChips<type>, AppCard, StatusBadge.
// Route : /opportunites  |  Écran : Opportunités
class OpportunitesListScreen extends StatelessWidget {
  const OpportunitesListScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Opportunités");
}
