import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Afficher titre/message/date ; à l'ouverture appeler NotificationRepository.markRead(id) puis invalider la liste et le compteur.
//   Si le type l'indique (demande de mise en relation, validation...), proposer un lien vers l'écran concerné.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : InfoRow, AppButton.
// Route : /notifications/:id  |  Écran : Notification
class NotificationDetailScreen extends StatelessWidget {
  const NotificationDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Notification");
}
