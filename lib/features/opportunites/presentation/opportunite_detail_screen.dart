import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/info_row.dart';
import 'package:mlc_mobile/core/widgets/section_header.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_models.dart';
import 'package:mlc_mobile/features/opportunites/presentation/opportunite_providers.dart';

/// Détail d'une opportunité : localité concernée, proximité avec le citoyen et candidature.
class OpportuniteDetailScreen extends ConsumerWidget {
  const OpportuniteDetailScreen({super.key, this.id});
  final String? id;

  BadgeTone _toneForType(OpportuniteType type) {
    return switch (type) {
      OpportuniteType.formationGratuite => BadgeTone.success,
      OpportuniteType.bourse => BadgeTone.accent,
      OpportuniteType.programme => BadgeTone.accent,
      OpportuniteType.concours => BadgeTone.success,
      _ => BadgeTone.neutral,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final oppId = id;
    if (oppId == null || oppId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Opportunité')),
        body: const ErrorView(error: NotFoundFailure('Identifiant manquant.')),
      );
    }

    final oppAsync = ref.watch(opportuniteDetailProvider(oppId));

    return Scaffold(
      appBar: AppBar(title: const Text('Détail de l\'opportunité')),
      body: AsyncValueView<Opportunite>(
        value: oppAsync,
        onRetry: () => ref.invalidate(opportuniteDetailProvider(oppId)),
        data: (opp) {
          final isUrgent =
              opp.expirationDate != null &&
              opp.expirationDate!.difference(DateTime.now()).inDays <= 5;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                children: [
                  StatusBadge(
                    label: opp.type.label,
                    tone: _toneForType(opp.type),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(
                    label: opp.status.label,
                    tone: opp.status == OpportuniteStatus.publiee
                        ? BadgeTone.success
                        : BadgeTone.neutral,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                opp.title,
                style: Theme.of(context).textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold, height: 1.3),
              ),
              const SizedBox(height: 24),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'Description'),
                    Text(
                      opp.description,
                      style: Theme.of(context).textTheme.bodyLarge
                          ?.copyWith(height: 1.5, color: AppColors.anthracite),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoRow(
                      icon: AppIcons.opportunites,
                      label: 'Type d\'opportunité',
                      value: opp.type.label,
                    ),
                    if (opp.categoryName != null)
                      InfoRow(
                        icon: AppIcons.more,
                        label: 'Catégorie / Secteur',
                        value: opp.categoryName!,
                      ),
                    InfoRow(
                      icon: AppIcons.calendar,
                      label: 'Date de publication',
                      value: formatDateFr(opp.publishedAt),
                    ),
                    if (opp.expirationDate != null)
                      InfoRow(
                        icon: AppIcons.calendar,
                        label: 'Date d\'expiration',
                        value: formatDateFr(opp.expirationDate!),
                      ),
                    InfoRow(
                      icon: AppIcons.location,
                      label: 'Localité concernée',
                      value: opp.localite ?? 'Tout le Mali',
                    ),
                  ],
                ),
              ),
              if (isUrgent) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withAlpha(51)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        AppIcons.error,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Attention : Les candidatures ferment bientôt (le ${formatDateFr(opp.expirationDate!)}).',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (opp.proximite?.estLocale ?? false) ...[
                const SizedBox(height: 16),
                AppCard(
                  child: Row(children: [
                    const Icon(AppIcons.location, color: AppColors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${opp.proximite!.label} : en tant qu’habitant de la localité, votre candidature est présentée en priorité.',
                        style: const TextStyle(fontSize: 13, color: AppColors.anthracite),
                      ),
                    ),
                  ]),
                ),
              ],
              const SizedBox(height: 28),
              if (opp.dejaPostule)
                AppCard(
                  child: Row(children: [
                    const Icon(AppIcons.check, color: AppColors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        switch (opp.statutCandidature) {
                          'RETENUE' => 'Votre candidature a été retenue. Vous serez contacté prochainement.',
                          'NON_RETENUE' => 'Votre candidature n’a pas été retenue cette fois-ci.',
                          _ => 'Candidature envoyée. Vous serez prévenu de la suite par notification.',
                        },
                        style: const TextStyle(fontSize: 13, color: AppColors.anthracite),
                      ),
                    ),
                  ]),
                )
              else
                AppButton(
                  label: 'Postuler',
                  icon: AppIcons.arrowRight,
                  onPressed: () => _postuler(context, ref, opp),
                ),
              if (opp.externalUrl != null && opp.externalUrl!.isNotEmpty) ...[
                const SizedBox(height: 12),
                AppButton(
                  label: 'Copier le lien de l’annonce',
                  variant: AppButtonVariant.secondary,
                  icon: AppIcons.copy,
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: opp.externalUrl!));
                    showSuccess(
                      context,
                      'Lien de candidature copié dans le presse-papiers',
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _postuler(BuildContext context, WidgetRef ref, Opportunite opp) async {
    final message = TextEditingController();
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (sheet) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + MediaQuery.of(sheet).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Postuler', style: Theme.of(sheet).textTheme.titleLarge),
            const SizedBox(height: 6),
            Text(opp.title, style: const TextStyle(color: AppColors.muted)),
            const SizedBox(height: 16),
            TextField(
              controller: message,
              maxLines: 4,
              maxLength: 2000,
              decoration: const InputDecoration(
                labelText: 'Message (facultatif)',
                hintText: 'Présentez-vous en quelques mots : expérience, disponibilité…',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Votre profil (compétences et localité) est transmis avec la candidature.',
              style: TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            AppButton(label: 'Envoyer ma candidature', onPressed: () => Navigator.of(sheet).pop(true)),
          ],
        ),
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(opportuniteRepositoryProvider).postuler(opp.id, message: message.text);
      ref.invalidate(opportuniteDetailProvider(opp.id));
      if (context.mounted) showSuccess(context, 'Candidature envoyée.');
    } catch (e) {
      if (context.mounted) showError(context, failureMessage(e));
    }
  }
}
