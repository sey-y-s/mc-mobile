import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/media/ouvrir_fichier.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/evaluateur/domain/evaluateur_models.dart';
import 'package:mlc_mobile/features/evaluateur/presentation/evaluateur_providers.dart';

/// Espace évaluateur : un citoyen désigné par son centre y traite les demandes d'évaluation,
/// consulte l'historique de ses décisions et retrouve ses centres.
class EvaluateurScreen extends ConsumerWidget {
  const EvaluateurScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final centres = ref.watch(evaluatorCentresProvider);
    final enAttente = ref
        .watch(evaluateurDemandesProvider)
        .asData
        ?.value
        .length;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Espace évaluateur'),
          bottom: TabBar(
            tabs: [
              Tab(
                text: enAttente == null || enAttente == 0
                    ? 'À évaluer'
                    : 'À évaluer ($enAttente)',
              ),
              const Tab(text: 'Historique'),
              const Tab(text: 'Mes centres'),
            ],
          ),
        ),
        body: centres.when(
          loading: () => const LoadingView(),
          error: (e, _) => ErrorView(
            error: e,
            onRetry: () => ref.invalidate(evaluatorCentresProvider),
          ),
          data: (liste) => liste.isEmpty
              ? const EmptyView(
                  message:
                      'Vous n’êtes désigné évaluateur dans aucun centre.\n'
                      'L’administrateur d’un centre doit d’abord vous désigner.',
                )
              : TabBarView(
                  children: [
                    _ListeDemandes(
                      provider: evaluateurDemandesProvider,
                      vide: 'Aucune demande à évaluer pour le moment.',
                      entete: true,
                    ),
                    _ListeDemandes(
                      provider: evaluateurHistoriqueProvider,
                      vide: 'Aucune décision rendue pour le moment.',
                    ),
                    _MesCentres(centres: liste),
                  ],
                ),
        ),
      ),
    );
  }
}

class _ListeDemandes extends ConsumerWidget {
  const _ListeDemandes({
    required this.provider,
    required this.vide,
    this.entete = false,
  });
  final FutureProvider<List<DemandeEvaluation>> provider;
  final String vide;
  final bool entete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final valeur = ref.watch(provider);
    return AsyncValueView<List<DemandeEvaluation>>(
      value: valeur,
      onRetry: () => ref.invalidate(provider),
      isEmpty: (d) => d.isEmpty,
      emptyMessage: vide,
      data: (liste) => RefreshIndicator(
        onRefresh: () => ref.refresh(provider.future),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            if (entete) ...[
              _Entete(total: liste.length),
              const SizedBox(height: 16),
            ],
            for (final d in liste) ...[
              _CarteDemande(demande: d),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _Entete extends StatelessWidget {
  const _Entete({required this.total});
  final int total;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.greenDark, AppColors.green],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ESPACE ÉVALUATEUR',
          style: TextStyle(
            color: AppColors.goldSoft,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          total == 0
              ? 'Rien à évaluer pour le moment.'
              : '$total demande${total > 1 ? 's' : ''} à évaluer.',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Examinez chaque demande avant de décider : une validation engage la crédibilité du centre.',
          style: TextStyle(color: Colors.white70, height: 1.35),
        ),
      ],
    ),
  );
}

class _CarteDemande extends ConsumerStatefulWidget {
  const _CarteDemande({required this.demande});
  final DemandeEvaluation demande;

  @override
  ConsumerState<_CarteDemande> createState() => _CarteDemandeState();
}

class _CarteDemandeState extends ConsumerState<_CarteDemande> {
  bool _occupe = false;

  DemandeEvaluation get d => widget.demande;

  Future<void> _ouvrirPreuve() async {
    try {
      await ouvrirFichierProtege(ref, d.preuveUrl!, nom: d.preuveTitre);
    } catch (e) {
      if (mounted) showError(context, failureMessage(e));
    }
  }

  Future<void> _decider(bool approuver) async {
    final choix = await showModalBottomSheet<_Decision>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FeuilleDecision(demande: d, approuver: approuver),
    );
    if (choix == null || !mounted) return;
    setState(() => _occupe = true);
    try {
      await ref
          .read(dioProvider)
          .patch<dynamic>(
            '/api/v1/evaluateur/demandes/${d.id}/decision',
            data: {
              'statut': approuver ? 'APPROUVEE' : 'REJETEE',
              'commentaire': choix.commentaire,
              if (approuver && choix.niveau != null)
                'niveauValide': choix.niveau,
            },
          );
      ref.read(evaluateurRevisionProvider.notifier).state++;
      if (mounted) {
        showSuccess(
          context,
          approuver ? 'Compétence validée.' : 'Demande refusée.',
        );
      }
    } catch (e) {
      if (mounted) showError(context, failureMessage(e));
    } finally {
      if (mounted) setState(() => _occupe = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      accentColor: d.enAttente
          ? AppColors.gold
          : (d.statut == 'APPROUVEE' ? AppColors.green : AppColors.error),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(d.citoyenNom, style: text.titleMedium)),
              if (!d.enAttente)
                StatusBadge(
                  label: d.statut == 'APPROUVEE' ? 'Validée' : 'Refusée',
                  tone: d.statut == 'APPROUVEE'
                      ? BadgeTone.success
                      : BadgeTone.error,
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(d.competenceNom, style: text.titleSmall),
          Text(
            'Niveau déclaré : ${d.niveauLabel}',
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              StatusBadge(label: d.typeLabel),
              if (d.centreNom != null) StatusBadge(label: d.centreNom!),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Demande du ${formatDateFr(d.dateDemande)}',
            style: text.bodySmall?.copyWith(color: AppColors.muted),
          ),
          if (d.preuveTitre != null || d.preuveDescription != null) ...[
            const SizedBox(height: 8),
            if (d.preuveTitre != null)
              Text('Justificatif : ${d.preuveTitre}', style: text.bodyMedium),
            if (d.preuveDescription != null)
              Text(d.preuveDescription!, style: text.bodySmall),
          ],
          if (d.commentaire != null) ...[
            const SizedBox(height: 8),
            Text(
              'Note : ${d.commentaire}',
              style: text.bodySmall?.copyWith(fontStyle: FontStyle.italic),
            ),
          ],
          if (d.enAttente) ...[
            const SizedBox(height: 10),
            if (d.preuveUrl != null)
              OutlinedButton.icon(
                onPressed: _ouvrirPreuve,
                icon: const Icon(Icons.description_outlined, size: 18),
                label: const Text('Voir le justificatif'),
              ),
            if (d.portfolio)
              OutlinedButton.icon(
                onPressed: () =>
                    context.push('/evaluateur/demandes/${d.id}/portfolio'),
                icon: const Icon(Icons.photo_library_outlined, size: 18),
                label: const Text('Voir le portfolio du citoyen'),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 46),
                    ),
                    onPressed: _occupe ? null : () => _decider(true),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Valider'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 46),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: _occupe ? null : () => _decider(false),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Refuser'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _Decision {
  const _Decision(this.commentaire, this.niveau);
  final String commentaire;
  final String? niveau;
}

/// Décision motivée : un refus exige toujours une explication (elle est transmise au citoyen) ;
/// une validation peut reconnaître un niveau différent de celui qui était déclaré.
class _FeuilleDecision extends StatefulWidget {
  const _FeuilleDecision({required this.demande, required this.approuver});
  final DemandeEvaluation demande;
  final bool approuver;

  @override
  State<_FeuilleDecision> createState() => _FeuilleDecisionState();
}

class _FeuilleDecisionState extends State<_FeuilleDecision> {
  final _note = TextEditingController();
  late String? _niveau = widget.demande.niveau;
  String? _erreur;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _valider() {
    final texte = _note.text.trim();
    if (!widget.approuver && texte.isEmpty) {
      setState(() => _erreur = 'Expliquez le refus : le citoyen le lira.');
      return;
    }
    Navigator.of(context).pop(_Decision(texte, _niveau));
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.approuver ? 'Valider la compétence' : 'Refuser la demande',
              style: text.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.demande.citoyenNom} · ${widget.demande.competenceNom}',
              style: text.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            if (widget.approuver) ...[
              const SizedBox(height: 16),
              Text('Niveau reconnu', style: text.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final n in const ['DEBUTANT', 'INTERMEDIAIRE', 'EXPERT'])
                    ChoiceChip(
                      label: Text(DemandeEvaluation.niveauDe(n)),
                      selected: _niveau == n,
                      onSelected: (_) => setState(() => _niveau = n),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _note,
              maxLines: 3,
              maxLength: 1000,
              decoration: InputDecoration(
                labelText: widget.approuver
                    ? 'Commentaire (facultatif)'
                    : 'Motif du refus',
                errorText: _erreur,
              ),
            ),
            const SizedBox(height: 8),
            FilledButton(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: widget.approuver ? null : AppColors.error,
              ),
              onPressed: _valider,
              child: Text(
                widget.approuver
                    ? 'Confirmer la validation'
                    : 'Confirmer le refus',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MesCentres extends StatelessWidget {
  const _MesCentres({required this.centres});
  final List<Map<String, dynamic>> centres;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      for (final c in centres) ...[
        AppCard(
          child: Row(
            children: [
              const Icon(Icons.verified_user_outlined, color: AppColors.green),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c['nomCentre']?.toString() ?? 'Centre',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    Text(
                      c['specialite']?.toString().isNotEmpty == true
                          ? 'Spécialité : ${c['specialite']}'
                          : 'Évaluateur désigné',
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
      ],
    ],
  );
}
