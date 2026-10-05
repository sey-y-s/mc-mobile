import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Changer le mot de passe (ancien + nouveau, Validators.password). Endpoint à définir. Option : fermer les autres sessions.

//   COMPOSANTS À RÉUTILISER (ne pas recréer) : FormScaffold, AppTextField.
// Route : /parametres/securite  |  Écran : Sécurité
class SecuritySettingsScreen extends StatelessWidget {
  const SecuritySettingsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Sécurité");
}
