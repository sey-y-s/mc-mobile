import 'package:flutter/material.dart';
import 'package:mlc_mobile/core/widgets/placeholder_screen.dart';

// TODO: Afficher message, statut, dates. Si reçue et EN_ATTENTE : boutons Accepter / Refuser (confirmDialog pour refuser).
//   MiseEnRelationRepository.respond(id, accept). Les coordonnées ne sont visibles QUE si ACCEPTEE (le serveur les fournit).
//   Ne pas gérer d'entretien, contrat ou recrutement : le processus s'arrête ici.
//   COMPOSANTS À RÉUTILISER (ne pas recréer) : InfoRow, StatusBadge, AppButton, confirmDialog.
// Route : /relations/:id  |  Écran : Détail de la demande
class RelationDetailScreen extends StatelessWidget {
  const RelationDetailScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context) =>
      const PlaceholderScreen(title: "Détail de la demande");
}
