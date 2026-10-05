import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Une question par écran, ordre = Question.ordre. Types : choix unique, choix multiple, vrai/faux, réponse libre.
//   TestSessionController (Notifier) : index courant, réponses, progression. Sauvegarde locale en mémoire ; soumission à la fin.
//   Dernière question : TestNumeriqueRepository.submit(answers) -> ResultatTest, puis context.go('/tests/:id/resultat').
//   Confirmer avant de quitter (confirmDialog). Ne jamais envoyer les propositions correctes au client si le backend ne le veut pas.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : AppProgressBar, AppButton, confirmDialog.
// Route : /tests/:id/question  |  Écran : Question
class TestQuestionScreen extends StatelessWidget {
  const TestQuestionScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Question");
}
