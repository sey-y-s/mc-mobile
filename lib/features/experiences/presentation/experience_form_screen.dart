import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Formulaire : titre (obligatoire), description, entreprise, dateDebut (obligatoire), dateFin, enCours, reconversion.
//   Validations : dateFin >= dateDebut ; dateFin ignorée/désactivée si enCours ; titre <= 120 car.
//   Compétences mobilisées : multi-sélection parmi les CitoyenCompetence DÉJÀ déclarées (jamais le référentiel directement).
//   Créer via ExperienceFormController (AutoDisposeAsyncNotifier) -> ExperienceRepository.create(). Succès : invalidate liste + pop.
//   Même écran réutilisé en modification (voir ExperienceEditScreen).
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : FormScaffold, AppTextField, confirmDialog.
// Route : /experiences/nouvelle  |  Écran : Nouvelle expérience
class ExperienceFormScreen extends StatelessWidget {
  const ExperienceFormScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Nouvelle expérience");
}
