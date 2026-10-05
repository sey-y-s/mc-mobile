import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Pré-remplir ExperienceFormScreen avec ExperienceRepository.get(id) (extraire le formulaire en widget partagé).
//   Enregistrer via ExperienceRepository.update(). Mêmes validations que la création.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : FormScaffold (même formulaire que la création).
// Route : /experiences/:id/modifier  |  Écran : Modifier l'expérience
class ExperienceEditScreen extends StatelessWidget {
  const ExperienceEditScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Modifier l'expérience");
}
