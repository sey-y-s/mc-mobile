import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/progressive_choice.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_progress_bar.dart';
import 'package:mlc_mobile/core/widgets/info_row.dart';
import 'package:mlc_mobile/core/widgets/section_header.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';
import 'package:mlc_mobile/features/competences/presentation/competences_providers.dart';
import 'package:mlc_mobile/features/preuves/presentation/preuve_providers.dart';
import 'package:mlc_mobile/shared/widgets/etat_badge.dart';
import 'package:mlc_mobile/shared/widgets/preuve_tile.dart';

import 'package:mlc_mobile/features/validations/presentation/validation_labels.dart';
import 'package:mlc_mobile/features/validations/presentation/validation_providers.dart';
import 'package:mlc_mobile/shared/widgets/validation_tile.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/features/tests/domain/test_numerique_models.dart';
import 'package:mlc_mobile/features/tests/presentation/test_numerique_providers.dart';

/// Route : /competences/:id
class CompetenceDetailScreen extends ConsumerWidget {
  const CompetenceDetailScreen({super.key, this.id});
  final String? id;

  static double _trust(EtatCompetence e) => switch (e) {
    EtatCompetence.declaree => 1 / 3,
    EtatCompetence.attestee => 2 / 3,
    EtatCompetence.validee => 1,
  };

  static String _trustHelp(EtatCompetence e) => switch (e) {
    EtatCompetence.declaree => 'Vous avez déclaré cette compétence. Ajoutez une preuve pour la rendre attestée.',
    EtatCompetence.attestee => 'Une preuve est jointe. Une validation par un évaluateur ou un centre la rendra validée.',
    EtatCompetence.validee =>
      'Cette compétence a été confirmée par un évaluateur ou un centre.',
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = this.id;
    if (id == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Compétence')),
        body: const ErrorView(error: NotFoundFailure()),
      );
    }
    final value = ref.watch(competenceDetailProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Compétence')),
      body: AsyncValueView<CitoyenCompetence>(
        value: value,
        onRetry: () => ref.invalidate(competenceDetailProvider(id)),
        data: (c) => _Content(item: c),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.item});
  final CitoyenCompetence item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(item.competenceNom, style: text.headlineSmall),
        if (item.secteurNom != null)
          Text(
            item.secteurNom!,
            style: text.bodyMedium?.copyWith(color: AppColors.muted),
          ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          children: [
            StatusBadge(label: item.niveau.label),
            EtatBadge(item.etat),
            if (item.parcours != null) StatusBadge(label: item.parcours!.label),
          ],
        ),
        const SizedBox(height: 24),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppProgressBar(
                label: 'Niveau de confiance',
                value: CompetenceDetailScreen._trust(item.etat),
              ),
              const SizedBox(height: 10),
              Text(
                CompetenceDetailScreen._trustHelp(item.etat),
                style: text.bodySmall?.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        ),
        if (item.etat != EtatCompetence.validee) ...[
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Comment valider cette compétence ?',
                  style: text.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Nous vous proposons le parcours le plus adapté, sans test inutile.',
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 12),
                AppButton(
                  label: 'Voir mon parcours de validation',
                  onPressed: () =>
                      context.push('/competences/${item.id}/parcours'),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 12),
        AppCard(
          child: InfoRow(
            label: 'Déclarée le',
            value: formatDateFr(item.dateDeclaration),
          ),
        ),
        const SizedBox(height: 28),
        SectionHeader(
          title: 'Preuves',
          actionLabel: item.parcours == null ? null : 'Ajouter',
          onAction: item.parcours == null
              ? null
              : () => context.push('/preuves/ajouter?competenceId=${item.id}'),
        ),
        if (item.parcours == null)
          _ParcoursChooser(item: item)
        else ...[
          _ProofsGuide(item: item),
          const SizedBox(height: 12),
          _ProofsBlock(competenceId: item.id),
        ],
        const SizedBox(height: 20),
        const SectionHeader(title: 'Test numérique'),
        _TestsBlock(competenceId: item.competenceId),
        const SizedBox(height: 20),

        SectionHeader(
          title: 'Validations',
          actionLabel: item.etat == EtatCompetence.validee
              ? null
              : 'Mon parcours',
          onAction: item.etat == EtatCompetence.validee
              ? null
              : () => context.push('/competences/${item.id}/parcours'),
        ),
        _ValidationsBlock(competenceId: item.id),
      ],
    );
  }
}

class _ProofsBlock extends ConsumerWidget {
  const _ProofsBlock({required this.competenceId});
  final String competenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(preuvesForCompetenceProvider(competenceId));
    return value.when(
      loading: () => const SizedBox(height: 80, child: LoadingView()),
      error: (e, _) => SizedBox(
        height: 160,
        child: ErrorView(
          error: e,
          onRetry: () =>
              ref.invalidate(preuvesForCompetenceProvider(competenceId)),
        ),
      ),
      data: (items) => items.isEmpty
          ? const _PendingBlock('Aucune preuve jointe pour le moment.')
          : Column(
              children: [
                for (final p in items) ...[
                  PreuveTile(
                    typeLabel: p.type.label,
                    competenceNom: p.competenceNom,
                    dateLabel: formatDateFr(p.date),
                    onTap: () => context.push('/preuves/${p.id}'),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

class _PendingBlock extends StatelessWidget {
  const _PendingBlock(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Text(
      message,
      style: Theme.of(context).textTheme.bodyMedium
          ?.copyWith(color: AppColors.muted),
    ),
  );
}

class _ValidationsBlock extends ConsumerWidget {
  const _ValidationsBlock({required this.competenceId});
  final String competenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(validationsForCompetenceProvider(competenceId));
    return value.when(
      loading: () => const SizedBox(height: 80, child: LoadingView()),
      error: (e, _) => SizedBox(
        height: 160,
        child: ErrorView(
          error: e,
          onRetry: () =>
              ref.invalidate(validationsForCompetenceProvider(competenceId)),
        ),
      ),
      data: (items) => items.isEmpty
          ? const _PendingBlock(
              "Aucune validation pour l'instant. Ajoutez une preuve, puis demandez une validation.",
            )
          : Column(
              children: [
                for (final v in items) ...[
                  ValidationTile(
                    typeLabel: v.type.label,
                    statut: v.statut,
                    dateLabel: validationDateLabel(v),
                    validateurLabel: v.validateurLabel,
                    onTap: () => context.push('/validations/${v.id}'),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}

/// Rappel des preuves attendues selon le secteur, avec les actions possibles.
class _ProofsGuide extends StatelessWidget {
  const _ProofsGuide({required this.item});
  final CitoyenCompetence item;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final informel = item.parcours == Parcours.informel;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(item.parcours!.label, style: text.titleSmall),
          const SizedBox(height: 4),
          Text(
            informel
                ? "Joignez le certificat délivré par un centre professionnel. Sans certificat, la démarche adaptée à votre cas vous est proposée dans « Voir mon parcours de validation »."
                : 'Joignez votre diplôme, certificat, attestation ou attestation de stage, puis suivez votre parcours de validation.',
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

/// Compétence déclarée avant l'arrivée des secteurs : le citoyen indique d'abord comment il a appris.
class _ParcoursChooser extends ConsumerStatefulWidget {
  const _ParcoursChooser({required this.item});
  final CitoyenCompetence item;

  @override
  ConsumerState<_ParcoursChooser> createState() => _ParcoursChooserState();
}

class _ParcoursChooserState extends ConsumerState<_ParcoursChooser> {
  late Parcours? _choice = widget.item.parcoursPossibles.length == 1
      ? widget.item.parcoursPossibles.first
      : null;

  Future<void> _save() async {
    final ok = await ref
        .read(parcoursControllerProvider.notifier)
        .submit(widget.item.id, _choice!);
    if (ok && mounted) showSuccess(context, 'Secteur enregistré');
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parcoursControllerProvider);
    final busy = state.isLoading;
    final possibles = widget.item.parcoursPossibles;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _PendingBlock(
          'Pour joindre vos preuves, indiquez d\'abord comment vous avez appris cette compétence.',
        ),
        const SizedBox(height: 12),
        ProgressiveChoice<Parcours>(
          options: possibles,
          selected: _choice,
          enabled: !busy,
          singleNote: Parcours.noteUnique(possibles),
          titleOf: (p) => p.label,
          descriptionOf: (p) => p.description,
          detailsOf: (p) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _PendingBlock(
              'Preuves acceptées : ${p.preuves.map((t) => t.label.toLowerCase()).join(', ')}.',
            ),
          ),
          onChanged: (p) => setState(() => _choice = p),
        ),
        if (state.hasError) ...[
          Text(
            failureMessage(state.error!),
            style: const TextStyle(color: AppColors.error),
          ),
          const SizedBox(height: 8),
        ],
        AnimatedOpacity(
          opacity: _choice == null ? .5 : 1,
          duration: const Duration(milliseconds: 250),
          child: AppButton(
            label: 'Enregistrer',
            onPressed: _choice == null ? null : _save,
            isLoading: busy,
          ),
        ),
      ],
    );
  }
}

/// Tests numériques proposés pour cette compétence : un test réussi (60 % ou plus) devient une preuve.
class _TestsBlock extends ConsumerWidget {
  const _TestsBlock({required this.competenceId});
  final String competenceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final value = ref.watch(testsForCompetenceProvider(competenceId));
    final text = Theme.of(context).textTheme;
    return value.when(
      loading: () => const SizedBox(height: 80, child: LoadingView()),
      error: (e, _) => SizedBox(
        height: 160,
        child: ErrorView(
          error: e,
          onRetry: () =>
              ref.invalidate(testsForCompetenceProvider(competenceId)),
        ),
      ),
      data: (tests) => tests.isEmpty
          ? const _PendingBlock(
              "Aucun test numérique n'est encore proposé pour cette compétence.",
            )
          : Column(
              children: [
                for (final TestNumerique t in tests) ...[
                  AppCard(
                    onTap: () => context.push('/tests/${t.id}'),
                    child: Row(
                      children: [
                        const Icon(
                          AppIcons.tests,
                          color: AppColors.green,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(t.title, style: text.titleSmall),
                              const SizedBox(height: 2),
                              Text(
                                t.lastResult == null
                                    ? 'Réussi à 60 % ou plus, il devient une preuve de cette compétence.'
                                    : t.lastResult!.passed
                                    ? 'Réussi (${t.lastResult!.score.toStringAsFixed(0)} %) : preuve ajoutée.'
                                    : 'Dernier score : ${t.lastResult!.score.toStringAsFixed(0)} %. Vous pouvez retenter.',
                                style: text.bodySmall?.copyWith(
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          t.lastResult == null ? 'Passer' : 'Retenter',
                          style: text.labelLarge?.copyWith(
                            color: AppColors.green,
                          ),
                        ),
                        const Icon(AppIcons.chevron, color: AppColors.muted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ),
    );
  }
}
