import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/contestations/data/contestation_repository.dart';
import 'package:mlc_mobile/features/contestations/presentation/contestation_providers.dart';
import 'package:mlc_mobile/features/contestations/presentation/contester_sheet.dart';

/// Route : /parametres/corrections — mes contestations et demandes de correction.
class CorrectionsScreen extends ConsumerWidget {
  const CorrectionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(mesContestationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Contester ou corriger')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        Text(
          'Pour contester une décision, ouvrez-la depuis « Validations ». '
          'Ici, vous pouvez aussi demander la correction d’une information de votre profil.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        AppButton(
          label: 'Demander une correction',
          icon: Icons.edit_note,
          onPressed: () => ouvrirContestation(context),
        ),
        const SizedBox(height: 24),
        value.when(
          loading: () => const SizedBox(height: 120, child: LoadingView()),
          error: (e, _) => SizedBox(
              height: 220, child: ErrorView(error: e, onRetry: () => ref.invalidate(mesContestationsProvider))),
          data: (items) => items.isEmpty
              ? Text('Vous n’avez encore envoyé aucune demande.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.muted))
              : Column(children: [
            for (final c in items) ...[
              AppCard(
                accentColor: switch (c.statut) {
                  StatutContestation.acceptee => AppColors.green,
                  StatutContestation.rejetee => AppColors.error,
                  _ => null,
                },
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Expanded(child: Text(c.titre, style: Theme.of(context).textTheme.titleSmall)),
                    StatusBadge(label: c.statut.label),
                  ]),
                  const SizedBox(height: 4),
                  Text('Envoyée le ${formatDateFr(c.dateCreation)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.muted)),
                  const SizedBox(height: 6),
                  Text(c.motif),
                  if (c.reponse != null) ...[
                    const SizedBox(height: 8),
                    Text('Réponse : ${c.reponse}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ]),
              ),
              const SizedBox(height: 12),
            ],
          ]),
        ),
      ]),
    );
  }
}
