import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Afficher/éditer téléphone et email du compte (Utilisateur). Changement de téléphone = revalidation (contrat backend à définir).

//   COMPOSANTS À RÉUTILISER (ne pas recréer) : FormScaffold, AppTextField.
// Route : /parametres/compte  |  Écran : Compte
class AccountSettingsScreen extends StatelessWidget {
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Compte");
}
