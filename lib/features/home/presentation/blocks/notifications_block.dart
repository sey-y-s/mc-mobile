import 'package:flutter/material.dart';

// TODO(NOTIFICATIONS): bloc « Dernières notifications » de l'accueil, à remplacer par le vrai contenu.
//   - Transformer en ConsumerWidget ; afficher les 3 dernières notifications NON LUES (réutiliser AppCard, SectionHeader).
//   - Contenu : SectionHeader(title: 'Notifications', actionLabel: 'Voir tout') qui mène à /notifications ;
//     chaque ligne ouvre /notifications/:id.
//   - Le bloc gère lui-même son espacement du haut (SizedBox(height: 28) puis le contenu) et retourne
//     SizedBox.shrink() quand il n'y a rien à montrer (aucun espace vide sur l'accueil).
//   - Chargement : petit indicateur ; erreur : message discret avec « Réessayer » (un échec ne doit jamais
//     bloquer le reste de l'accueil).
class NotificationsBlock extends StatelessWidget {
  const NotificationsBlock({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}