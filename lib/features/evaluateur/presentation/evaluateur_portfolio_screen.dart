import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/features/evaluateur/presentation/evaluateur_providers.dart';
import 'package:mlc_mobile/features/portfolio/presentation/realisation_card.dart';

/// Route : /evaluateur/demandes/:id/portfolio — réalisations du citoyen, pour une évaluation sur portfolio.
class EvaluateurPortfolioScreen extends ConsumerWidget {
  const EvaluateurPortfolioScreen({super.key, required this.demandeId});
  final String demandeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valeur = ref.watch(evaluateurPortfolioProvider(demandeId));
    return Scaffold(
      appBar: AppBar(title: const Text('Portfolio du citoyen')),
      body: AsyncValueView<List<Map<String, dynamic>>>(
        value: valeur,
        onRetry: () => ref.invalidate(evaluateurPortfolioProvider(demandeId)),
        isEmpty: (d) => d.isEmpty,
        emptyMessage: 'Ce citoyen n’a encore ajouté aucune réalisation.',
        data: (liste) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final r in liste) ...[
              RealisationCard(r: r),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
