import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Profil ANONYMISÉ (TalentRepository.getAnonymized(id)). Compétences + niveaux + validations + preuves + portfolio éventuel.
//   Bouton « Demander une mise en relation » -> bottom sheet (message optionnel) -> MiseEnRelationRepository.send().
//   Si une demande existe déjà : afficher son statut au lieu du bouton. Chaque consultation est tracée côté serveur (ConsultationProfil).
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : ProfileHeader(anonymized: true), CompetenceCard, SectionHeader, showAppBottomSheet (demande).
// Route : /talents/:id  |  Écran : Profil du talent
class TalentProfileScreen extends StatelessWidget {
  const TalentProfileScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Profil du talent");
}
