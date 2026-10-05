import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: ExperienceRepository.get(id). Afficher toutes les informations + compétences mobilisées.
//   Actions : modifier (/experiences/:id/modifier) ; supprimer avec confirmDialog(destructive: true) puis ExperienceRepository.delete().
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : SectionHeader, InfoRow, StatusBadge, CompetenceCard, confirmDialog.
// Route : /experiences/:id  |  Écran : Détail expérience
class ExperienceDetailScreen extends StatelessWidget {
  const ExperienceDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Détail expérience");
}
