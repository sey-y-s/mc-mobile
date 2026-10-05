import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Champs : code reçu, nouveau mot de passe (Validators.password), confirmation (Validators.confirmPassword).
//   Appeler AuthRepository.resetPassword(code:, newPassword:) ; succès => showSuccess + context.go('/login').
//   États : loading, erreur (code invalide = ValidationFailure). Contrat backend provisoire (ApiEndpoints.resetPassword).
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : FormScaffold, AppTextField.
// Route : /reset-password  |  Écran : Réinitialisation
class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Réinitialisation");
}
