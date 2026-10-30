import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/section_header.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/competences/presentation/competences_providers.dart';
import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_models.dart';
import 'package:mlc_mobile/features/parcours_validation/presentation/parcours_validation_providers.dart';

/// Route : /competences/:id/parcours (id = compétence du citoyen).
/// Le moteur propose le parcours de validation adapté ; le citoyen n'a pas à accumuler les tests.
class ParcoursValidationScreen extends ConsumerStatefulWidget {
  const ParcoursValidationScreen({super.key, this.id});
  final String? id;

  @override
  ConsumerState<ParcoursValidationScreen> createState() => _ParcoursValidationScreenState();
}

class _ParcoursValidationScreenState extends ConsumerState<ParcoursValidationScreen> {
  bool _envoi = false;

  Future<void> _agir(ParcoursValidation parcours, ModaliteProposee proposition) async {
    switch (proposition.action) {
      case 'DEPOSER_PREUVE':
        await context.push('/preuves/ajouter?competenceId=${parcours.citoyenCompetenceId}');
      case 'PASSER_TEST':
        final testId = proposition.testId;
        if (testId != null) await context.push('/tests/$testId');
      case 'AJOUTER_REALISATIONS':
        await context.push('/portfolio/nouvelle');
      case 'DEMANDER_EVALUATION':
        await _demander(parcours, proposition);
    }
    if (mounted) ref.invalidate(parcoursValidationProvider(parcours.citoyenCompetenceId));
  }

  Future<void> _demander(ParcoursValidation parcours, ModaliteProposee proposition) async {
    CentreProche? centre;
    if (proposition.centres.length == 1) {
      centre = proposition.centres.first;
    } else {
      centre = await showModalBottomSheet<CentreProche>(
        context: context,
        showDragHandle: true,
        builder: (sheet) => SafeArea(
          child: ListView(shrinkWrap: true, padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), children: [
            Text('Choisissez un centre', style: Theme.of(sheet).textTheme.titleLarge),
            const SizedBox(height: 12),
            for (final c in proposition.centres)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(c.nom),
                subtitle: Text([c.proximite, c.adresse].whereType<String>().where((t) => t.isNotEmpty).join(' · ')),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(sheet).pop(c),
              ),
          ]),
        ),
      );
    }
    if (centre == null || !mounted) return;
    setState(() => _envoi = true);
    try {
      await ref.read(parcoursValidationRepositoryProvider).demanderEvaluation(
            citoyenCompetenceId: parcours.citoyenCompetenceId,
            modalite: proposition.modalite,
            centreId: centre.id,
          );
      ref.invalidate(competencesProvider);
      if (mounted) showSuccess(context, 'Demande envoyée à ${centre.nom} : vous serez prévenu de la décision.');
    } catch (e) {
      if (mounted) showError(context, failureMessage(e));
    } finally {
      if (mounted) setState(() => _envoi = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.id;
    if (id == null) {
      return Scaffold(
          appBar: AppBar(title: const Text('Valider ma compétence')),
          body: const ErrorView(error: NotFoundFailure()));
    }
    final value = ref.watch(parcoursValidationProvider(id));
    return Scaffold(
      appBar: AppBar(title: const Text('Valider ma compétence')),
      body: AsyncValueView<ParcoursValidation>(
        value: value,
        onRetry: () => ref.invalidate(parcoursValidationProvider(id)),
        data: (p) => _Contenu(parcours: p, envoi: _envoi, onAgir: (m) => _agir(p, m)),
      ),
    );
  }
}

class _Contenu extends StatelessWidget {
  const _Contenu({required this.parcours, required this.envoi, required this.onAgir});
  final ParcoursValidation parcours;
  final bool envoi;
  final void Function(ModaliteProposee) onAgir;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    // Le parcours est imposé : une seule démarche est proposée, celle que le serveur recommande.
    final imposee = parcours.modalites.where((m) => m.recommandee && m.disponible).firstOrNull;
    final indisponibles = parcours.modalites.where((m) => !m.disponible).toList();
    return ListView(padding: const EdgeInsets.all(20), children: [
      Text(parcours.competenceNom, style: text.headlineSmall),
      const SizedBox(height: 16),
      _Avancement(statut: parcours.statut),
      const SizedBox(height: 16),
      AppCard(
        accentColor: parcours.enAttenteEvaluation ? AppColors.gold : AppColors.green,
        child: Text(parcours.message, style: text.bodyMedium),
      ),
      if (imposee != null) ...[
        const SizedBox(height: 24),
        const SectionHeader(title: 'Votre démarche'),
        _CarteModalite(proposition: imposee, envoi: envoi, onAgir: () => onAgir(imposee)),
      ],
      // Quand rien n'est réalisable, on explique pourquoi (sans action possible) : le dossier attend.
      if (imposee == null && parcours.enAttenteEvaluation && indisponibles.isNotEmpty) ...[
        const SizedBox(height: 24),
        const SectionHeader(title: 'Pourquoi votre dossier attend'),
        for (final m in indisponibles) ...[
          _CarteModalite(proposition: m, envoi: envoi, onAgir: null),
          const SizedBox(height: 12),
        ],
      ],
    ]);
  }
}

/// Les 4 statuts d'avancement : Déclarée, Preuve reçue, En cours d'évaluation, Validée.
class _Avancement extends StatelessWidget {
  const _Avancement({required this.statut});
  final StatutParcours statut;

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: 8, runSpacing: 8, children: [
      for (final s in StatutParcours.values)
        StatusBadge(
          label: s.label,
          tone: s == statut
              ? (s == StatutParcours.validee ? BadgeTone.success : BadgeTone.accent)
              : BadgeTone.neutral,
        ),
    ]);
  }
}

class _CarteModalite extends StatelessWidget {
  const _CarteModalite({required this.proposition, required this.envoi, required this.onAgir});
  final ModaliteProposee proposition;
  final bool envoi;
  final VoidCallback? onAgir;

  static String _libelleAction(String? action) => switch (action) {
        'DEPOSER_PREUVE' => 'Déposer un justificatif',
        'PASSER_TEST' => 'Passer le test',
        'AJOUTER_REALISATIONS' => 'Ajouter mes réalisations',
        'DEMANDER_EVALUATION' => "Demander l'évaluation",
        _ => 'Continuer',
      };

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final disponible = proposition.disponible;
    return Opacity(
      opacity: disponible ? 1 : 0.6,
      child: AppCard(
        accentColor: proposition.recommandee ? AppColors.gold : null,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            Expanded(child: Text(proposition.libelle, style: text.titleMedium)),
          ]),
          const SizedBox(height: 6),
          Text(proposition.description, style: text.bodySmall?.copyWith(color: AppColors.muted)),
          if (proposition.raison != null && proposition.raison!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(proposition.raison!, style: text.bodyMedium),
          ],
          if (proposition.criteres != null && proposition.criteres!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text('Critères : ${proposition.criteres}', style: text.bodySmall?.copyWith(color: AppColors.muted)),
          ],
          if (disponible && proposition.centres.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              proposition.centres.length == 1
                  ? '${proposition.centres.first.nom} · ${proposition.centres.first.proximite ?? ''}'
                  : '${proposition.centres.length} centres possibles',
              style: text.bodySmall?.copyWith(color: AppColors.muted),
            ),
          ],
          if (disponible && onAgir != null) ...[
            const SizedBox(height: 12),
            AppButton(
              label: _libelleAction(proposition.action),
              variant: proposition.recommandee ? AppButtonVariant.primary : AppButtonVariant.secondary,
              isLoading: envoi && proposition.action == 'DEMANDER_EVALUATION',
              onPressed: envoi ? null : onAgir,
            ),
          ],
        ]),
      ),
    );
  }
}
