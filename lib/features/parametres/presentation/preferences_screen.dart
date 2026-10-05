import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Préférences locales (mode économie de données : désactive images/vidéos auto ; notifications). Stockage : SharedPreferences (données non sensibles uniquement).

//   COMPOSANTS À RÉUTILISER (ne pas recréer) : AppCard, SectionHeader.
// Route : /parametres/preferences  |  Écran : Préférences
class PreferencesScreen extends StatelessWidget {
  const PreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Préférences");
}
