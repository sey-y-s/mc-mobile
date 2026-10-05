import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Menu : Compte, Sécurité, Préférences, À propos (version via package_info_plus si besoin), Déconnexion.
//   Déconnexion : confirmDialog puis ref.read(authControllerProvider.notifier).logout() ; le routeur renvoie vers /login.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : AppCard, SectionHeader, confirmDialog (déconnexion).
// Route : /parametres  |  Écran : Paramètres
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Paramètres");
}
