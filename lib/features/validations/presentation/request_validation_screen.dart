import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/choice_sheet_field.dart';
import 'package:mlc_mobile/core/widgets/form_scaffold.dart';
import 'package:mlc_mobile/core/widgets/selectable_option_card.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';
import 'package:mlc_mobile/features/competences/presentation/competences_providers.dart';
import 'package:mlc_mobile/features/preuves/presentation/preuve_providers.dart';
import 'package:mlc_mobile/features/preuves/domain/preuve_models.dart';
import 'package:mlc_mobile/features/validations/domain/validation_statut.dart';
import 'package:mlc_mobile/features/validations/presentation/validation_providers.dart';

/// Route : /validations/demander?competenceId=&preuveId= (paramètres facultatifs).
/// Deux choix : la compétence (pas déjà validée), puis l'une de ses preuves.
/// Secteur informel sans certificat : le citoyen peut demander un test de validation au centre, sans preuve
/// (`&test=1` présélectionne cette option).
class RequestValidationScreen extends ConsumerStatefulWidget {
  const RequestValidationScreen({super.key, this.competenceId, this.preuveId, this.testCentre = false});
  final String? competenceId;
  final String? preuveId;
  final bool testCentre;

  @override
  ConsumerState<RequestValidationScreen> createState() => _RequestValidationScreenState();
}

class _RequestValidationScreenState extends ConsumerState<RequestValidationScreen> {
  final _formKey = GlobalKey<FormState>();
  late String? _competenceId = widget.competenceId;
  late String? _preuveId = widget.preuveId;
  late bool _testSansPreuve = widget.testCentre && widget.preuveId == null;
  bool _showErrors = false;
  String? _centreId;
  bool _loadingCentres = false;
  List<Map<String, dynamic>> _centres = [];

  @override
  void initState() {
    super.initState();
    final id = widget.competenceId;
    if (id != null) WidgetsBinding.instance.addPostFrameCallback((_) => _loadCentres(id));
  }

  /// Centres actifs, agréés pour la compétence et disposant d'un évaluateur habilité.
  Future<void> _loadCentres(String citoyenCompetenceId) async {
    setState(() {
      _loadingCentres = true;
      _centreId = null;
      _centres = [];
    });
    try {
      final response = await ref.read(dioProvider).get(
            '/api/v1/evaluateur/centres-disponibles',
            queryParameters: {'citoyenCompetenceId': citoyenCompetenceId},
          );
      final data = response.data;
      if (data is List) {
        _centres = data.whereType<Map>().map((e) => Map<String, dynamic>.from(e)).toList();
        // Un seul centre possible : il est choisi d'office.
        if (_centres.length == 1) _centreId = _centres.first['id']?.toString();
      }
    } catch (_) {
      // Les erreurs de chargement seront signalées par le formulaire si aucun centre n'est disponible.
    } finally {
      if (mounted) setState(() => _loadingCentres = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _showErrors = true);
    final comps = ref.read(competencesProvider).value ?? const <CitoyenCompetence>[];
    final competence = comps.where((c) => c.id == _competenceId).firstOrNull;
    final sansPreuve = _testSansPreuve && competence?.parcours == Parcours.informel;
    final manquant = _competenceId == null
        ? 'Choisissez la compétence à faire valider.'
        : _centreId == null
            ? (_centres.isEmpty ? "Aucun centre d'évaluation n'est disponible pour le moment." : "Choisissez le centre d'évaluation.")
            : (_preuveId == null && !sansPreuve)
                ? (competence?.parcours == Parcours.informel
                    ? 'Choisissez un certificat, ou « passer un test au centre ».'
                    : 'Choisissez la preuve à soumettre.')
                : null;
    if (manquant != null) {
      showError(context, manquant);
      return;
    }
    final ok = await ref.read(requestValidationControllerProvider.notifier).submit(
          citoyenCompetenceId: _competenceId!,
          preuveId: sansPreuve ? null : _preuveId,
          centreId: _centreId,
        );
    if (!mounted) return;
    if (!ok) {
      final error = ref.read(requestValidationControllerProvider).error;
      showError(context, error == null ? "L'envoi de la demande a échoué. Réessayez." : failureMessage(error));
      return;
    }
    showSuccess(context, sansPreuve ? 'Demande envoyée : le centre vous contactera pour le test.' : 'Demande envoyée');
    Navigator.of(context).maybePop();
  }

  Widget _shell(Widget body) => Scaffold(appBar: AppBar(title: const Text('Demander une validation')), body: body);

  @override
  Widget build(BuildContext context) {
    final comps = ref.watch(competencesProvider);
    final request = ref.watch(requestValidationControllerProvider);
    final busy = request.isLoading;
    final text = Theme.of(context).textTheme;

    return comps.when(
      skipLoadingOnReload: true,
      loading: () => _shell(const LoadingView()),
      error: (e, _) => _shell(ErrorView(error: e, onRetry: () => ref.invalidate(competencesProvider))),
      data: (items) {
        final eligible = items.where((c) => c.etat != EtatCompetence.validee).toList();
        if (eligible.isEmpty) {
          return _shell(EmptyView(
            message: items.isEmpty
                ? "Ajoutez d'abord une compétence pour pouvoir demander sa validation."
                : 'Toutes vos compétences sont déjà validées.',
            icon: AppIcons.validations,
            actionLabel: items.isEmpty ? 'Ajouter une compétence' : null,
            onAction: items.isEmpty ? () => context.push('/competences/ajouter') : null,
          ));
        }
        if (_competenceId == null && eligible.length == 1) {
          final seule = eligible.first.id;
          _competenceId = seule;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) _loadCentres(seule);
          });
        }
        final selected = eligible.where((c) => c.id == _competenceId).firstOrNull;
        final informel = selected?.parcours == Parcours.informel;
        return FormScaffold(
          title: 'Demander une validation',
          formKey: _formKey,
          submitLabel: 'Envoyer la demande',
          onSubmit: _submit,
          isLoading: busy,
          error: request.hasError ? request.error : null,
          children: [
            Text(
              informel && _testSansPreuve
                  ? 'Un évaluateur du centre choisi vous fera passer un test pratique pour confirmer votre compétence.'
                  : 'Un évaluateur ou un centre examinera votre preuve et confirmera votre compétence.',
              style: text.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            ChoiceSheetField<CitoyenCompetence>(
              label: 'Compétence',
              placeholder: 'Choisir la compétence',
              options: eligible,
              labelOf: (c) => c.competenceNom,
              selected: selected,
              enabled: !busy,
              errorText: _showErrors && selected == null ? 'Choisissez la compétence à faire valider' : null,
              onChanged: (c) => setState(() {
                if (c.id != _competenceId) {
                  _preuveId = null; // la preuve dépend de la compétence
                  if (c.parcours != Parcours.informel) _testSansPreuve = false;
                }
                final change = c.id != _competenceId;
                _competenceId = c.id;
                if (change) _loadCentres(c.id);
              }),
            ),
            // Centres proposés APRÈS le choix de la compétence : seulement ceux qui sont actifs,
            // agréés pour cette compétence et qui ont un évaluateur habilité.
            if (selected != null) ...[
              if (_loadingCentres)
                const LinearProgressIndicator()
              else if (_centres.isEmpty)
                const Text('Aucun centre agréé n’évalue encore cette compétence. Revenez plus tard ou choisissez une autre compétence.')
              else
                DropdownButtonFormField<String>(
                  key: ValueKey('centres-${selected.id}-${_centres.length}'),
                  initialValue: _centreId,
                  decoration: InputDecoration(
                    labelText: 'Centre d’évaluation',
                    errorText: _showErrors && _centreId == null ? 'Choisissez un centre' : null,
                  ),
                  items: _centres.map((c) => DropdownMenuItem<String>(
                    value: c['id']?.toString(),
                    child: Text(c['nom']?.toString() ?? 'Centre', overflow: TextOverflow.ellipsis),
                  )).where((item) => item.value != null).toList(),
                  onChanged: busy ? null : (value) => setState(() => _centreId = value),
                ),
            ],
            if (selected == null)
              Text("Choisissez d'abord la compétence.", style: text.bodySmall?.copyWith(color: AppColors.muted))
            else
              _ProofsPicker(
                competenceId: selected.id,
                selectedId: _preuveId,
                busy: busy,
                informel: informel,
                testSansPreuve: informel && _testSansPreuve,
                showError: _showErrors && _preuveId == null && !(informel && _testSansPreuve),
                onSelect: (id) => setState(() {
                  _preuveId = id;
                  _testSansPreuve = false;
                }),
                onTestSansPreuve: () => setState(() {
                  _preuveId = null;
                  _testSansPreuve = true;
                }),
                onReset: () => setState(() {
                  _preuveId = null;
                  _testSansPreuve = false;
                }),
              ),
          ],
        );
      },
    );
  }
}

class _ProofsPicker extends ConsumerWidget {
  const _ProofsPicker({
    required this.competenceId,
    required this.selectedId,
    required this.busy,
    required this.showError,
    required this.onSelect,
    this.informel = false,
    this.testSansPreuve = false,
    this.onTestSansPreuve,
    this.onReset,
  });
  final String competenceId;
  final String? selectedId;
  final bool busy;
  final bool showError;
  final ValueChanged<String> onSelect;
  final bool informel;
  final bool testSansPreuve;
  final VoidCallback? onTestSansPreuve;

  /// Revenir à la liste complète des choix (lien « Changer »).
  final VoidCallback? onReset;

  /// Secteur informel : test de validation au centre, sans certificat.
  Widget _testOption() => SelectableOptionCard(
        title: 'Je n’ai pas de certificat : passer un test au centre',
        description: 'Vous maîtrisez le métier ? Un évaluateur du centre vous fera passer un test de validation.',
        selected: testSansPreuve,
        onTap: busy ? null : onTestSansPreuve,
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    final value = ref.watch(preuvesForCompetenceProvider(competenceId));
    return value.when(
      loading: () => const SizedBox(height: 80, child: LoadingView()),
      error: (e, _) => SizedBox(height: 160, child: ErrorView(error: e, onRetry: () => ref.invalidate(preuvesForCompetenceProvider(competenceId)))),
      data: (proofs) {
        if (proofs.isEmpty) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            if (informel) ...[_testOption(), const SizedBox(height: 12)],
            Text(
              informel
                  ? 'Ou ajoutez le certificat délivré par un centre professionnel.'
                  : "Cette compétence n'a pas encore de preuve. Ajoutez-en une pour demander une validation.",
              style: text.bodyMedium?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Ajouter une preuve',
              variant: AppButtonVariant.secondary,
              onPressed: () => context.push('/preuves/ajouter?competenceId=$competenceId'),
            ),
          ]);
        }
        // Choix progressif : une fois l'option retenue, les autres disparaissent.
        final choixFait = testSansPreuve || proofs.any((p) => p.id == selectedId);
        final visibles = testSansPreuve ? const <Preuve>[] : proofs.where((p) => !choixFait || p.id == selectedId).toList();
        return AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (informel && (!choixFait || testSansPreuve)) ...[_testOption(), const SizedBox(height: 10)],
          if (!choixFait) ...[
            Text(informel ? 'Ou soumettre un certificat :' : 'Quelle preuve soumettre ?', style: text.bodySmall?.copyWith(color: AppColors.muted)),
            const SizedBox(height: 8),
          ],
          for (final p in visibles) ...[
            Builder(builder: (_) {
              final available = p.statut == null || p.statut == ValidationStatut.rejetee;
              return Opacity(
                opacity: available ? 1 : 0.5,
                child: SelectableOptionCard(
                  title: p.type.label,
                  description: available
                      ? 'Ajoutée le ${formatDateFr(p.date)}'
                      : (p.statut == ValidationStatut.enAttente ? 'Validation en cours' : 'Déjà validée'),
                  selected: selectedId == p.id,
                  onTap: available && !busy ? () => onSelect(p.id) : null,
                ),
              );
            }),
            const SizedBox(height: 10),
          ],
          if (choixFait && (proofs.length > 1 || informel))
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: busy ? null : onReset,
                icon: const Icon(Icons.swap_horiz, size: 18),
                label: const Text('Changer'),
              ),
            ),
          if (showError) Text('Choisissez la preuve à soumettre', style: text.bodySmall?.copyWith(color: AppColors.error)),
        ]),
        );
      },
    );
  }
}