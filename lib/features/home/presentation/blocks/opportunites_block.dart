import 'package:flutter/material.dart';

// TODO(OPPORTUNITES): bloc « Opportunités récentes » de l'accueil, à remplacer par le vrai contenu.
//   - Transformer en ConsumerWidget ; afficher les 2 opportunités publiées les plus récentes (réutiliser AppCard, StatusBadge).
//   - Contenu : SectionHeader(title: 'Opportunités', actionLabel: 'Voir tout') qui mène à /opportunites ;
//     chaque ligne ouvre /opportunites/:id.
//   - Le bloc gère lui-même son espacement du haut (SizedBox(height: 28) puis le contenu) et retourne
//     SizedBox.shrink() quand il n'y a rien à montrer.
//   - Chargement : petit indicateur ; erreur : message discret avec « Réessayer ».
class OpportunitesBlock extends StatelessWidget {
  const OpportunitesBlock({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}