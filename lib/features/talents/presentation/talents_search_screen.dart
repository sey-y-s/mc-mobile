import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Recherche par compétence/métier (autocomplétion référentiel) + filtres (localisation, disponibilité, niveau) dans un bottom sheet.
//   Résultats paginés LÉGERS (TalentRepository.search) : AUCUN nom, téléphone ni email avant mise en relation acceptée.
//   Carte résultat : compétences clés, niveau, commune/région, disponibilité, badges validations/preuves/portfolio.
//   États : initial (invite à chercher), loading, empty, erreur. Debounce 400 ms ; annuler la requête précédente.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : PaginatedListView (key = filtres), FilterChips, showAppBottomSheet (filtres), CompetenceCard, EmptyView.
// Route : /talents  |  Écran : Recherche de talents
class TalentsSearchScreen extends StatelessWidget {
  const TalentsSearchScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Recherche de talents");
}
