import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Liste paginée (ExperienceRepository.list). Carte : titre, entreprise, période, badge « Reconversion » si reconversion.
//   AsyncValueView + FAB vers /experiences/nouvelle. Empty state : « Ajoutez votre première expérience ».
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : PaginatedListView, AppCard, SectionHeader.
// Route : /experiences  |  Écran : Mes expériences
class ExperiencesListScreen extends StatelessWidget {
  const ExperiencesListScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Mes expériences");
}
