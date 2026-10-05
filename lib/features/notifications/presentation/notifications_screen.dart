import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Liste paginée (NotificationRepository.list) : titre, extrait, date, point doré si non lue (NotificationDestinataire.lu).
//   Action « Tout marquer comme lu ». Badge du nombre de non lues sur l'onglet du AppShell (provider unreadCountProvider).
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : PaginatedListView, AppCard.
// Route : /notifications  |  Écran : Notifications
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Notifications");
}
