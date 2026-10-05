import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Formulaire d'un champ (téléphone ou email), validé avec Validators.required.
//   Au submit : AuthRepository.requestPasswordReset(identifiant) via un AsyncNotifier autoDispose (modèle : AuthController).
//   Succès : message neutre (« Si ce compte existe, un code a été envoyé ») puis context.push('/reset-password').
//   États : loading (AppButton.isLoading), erreur (failureMessage). Ne jamais révéler si le compte existe.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : FormScaffold, AppTextField.
// Route : /forgot-password  |  Écran : Mot de passe oublié
class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Mot de passe oublié");
}
