import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/media/picked_media.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/choice_sheet_field.dart';
import 'package:mlc_mobile/core/widgets/file_picker_field.dart';
import 'package:mlc_mobile/core/widgets/form_scaffold.dart';
import 'package:mlc_mobile/core/widgets/progressive_choice.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';
import 'package:mlc_mobile/features/competences/presentation/competences_providers.dart';
import 'package:mlc_mobile/features/preuves/domain/preuve_models.dart';
import 'package:mlc_mobile/features/preuves/presentation/preuve_providers.dart';

/// Route : `/preuves/ajouter?competenceId=<id d'une CitoyenCompetence>` (facultatif).
/// Trois choix : compétence, type de preuve, fichier (photo ou document).
/// Les types proposés dépendent du secteur de la compétence :
/// formel = diplôme, certificat, attestation, attestation de stage ; informel = certificat d'un centre professionnel.
class AddPreuveScreen extends ConsumerStatefulWidget {
  const AddPreuveScreen({super.key, this.competenceId});
  final String? competenceId;

  @override
  ConsumerState<AddPreuveScreen> createState() => _AddPreuveScreenState();
}

class _AddPreuveScreenState extends ConsumerState<AddPreuveScreen> {
  final _formKey = GlobalKey<FormState>();
  late String? _competenceId = widget.competenceId;
  PreuveType? _type;
  PickedMedia? _media;
  bool _showErrors = false;

  Future<void> _submit() async {
    setState(() => _showErrors = true);
    // Chaque champ manquant est signalé sous le champ ET par un message visible, jamais en silence.
    final manquant = _competenceId == null
        ? 'Choisissez la compétence concernée.'
        : _type == null
            ? 'Choisissez le type de preuve.'
            : _media == null
                ? 'Ajoutez la photo ou le document de la preuve.'
                : null;
    if (manquant != null) {
      showError(context, manquant);
      return;
    }
    final comps = ref.read(competencesProvider).value ?? const <CitoyenCompetence>[];
    final competence = comps.where((c) => c.id == _competenceId).firstOrNull;
    if (competence != null && !competence.preuvesAcceptees.contains(_type)) {
      showError(context, "Ce type de preuve n'est pas accepté pour cette compétence.");
      return;
    }
    final ok = await ref
        .read(addPreuveControllerProvider.notifier)
        .submit(
          citoyenCompetenceId: _competenceId!,
          type: _type!,
          media: _media!,
        );
    if (!mounted) return;
    if (!ok) {
      final error = ref.read(addPreuveControllerProvider).error;
      showError(context, error == null ? "L'envoi de la preuve a échoué. Réessayez." : failureMessage(error));
      return;
    }
    showSuccess(context, 'Preuve envoyée. Elle est maintenant jointe à votre compétence.');
    Navigator.of(context).maybePop();
  }

  Widget _shell(Widget body) => Scaffold(
    appBar: AppBar(title: const Text('Ajouter une preuve')),
    body: body,
  );

  @override
  Widget build(BuildContext context) {
    final comps = ref.watch(competencesProvider);
    final add = ref.watch(addPreuveControllerProvider);
    final progress = ref.watch(preuveProgressProvider);
    final busy = add.isLoading;
    final text = Theme.of(context).textTheme;

    return comps.when(
      skipLoadingOnReload: true,
      loading: () => _shell(const LoadingView()),
      error: (e, _) => _shell(
        ErrorView(error: e, onRetry: () => ref.invalidate(competencesProvider)),
      ),
      data: (items) {
        if (items.isEmpty) {
          return _shell(
            EmptyView(
              message: "Ajoutez d'abord une compétence pour pouvoir lui associer une preuve.",
              icon: Icons.workspace_premium_outlined,
              actionLabel: 'Ajouter une compétence',
              onAction: () => context.push('/competences/ajouter'),
            ),
          );
        }
        // Une seule compétence : elle est choisie d'office.
        if (_competenceId == null && items.length == 1) _competenceId = items.first.id;
        final selected = items.where((c) => c.id == _competenceId).firstOrNull;
        final types = selected?.preuvesAcceptees ?? const <PreuveType>[];
        // Type devenu incompatible après un changement de compétence.
        if (_type != null && !types.contains(_type)) _type = null;
        // Un seul type possible (ex. secteur informel : certificat de centre) : choisi d'office.
        if (types.length == 1) _type = types.first;
        return FormScaffold(
          title: 'Ajouter une preuve',
          formKey: _formKey,
          submitLabel: 'Envoyer la preuve',
          onSubmit: _submit,
          isLoading: busy,
          error: add.hasError ? add.error : null,
          children: [
            ChoiceSheetField<CitoyenCompetence>(
              label: 'Compétence',
              placeholder: 'Choisir la compétence',
              options: items,
              labelOf: (c) => c.competenceNom,
              selected: selected,
              enabled: !busy,
              errorText: _showErrors && selected == null
                  ? 'Choisissez la compétence concernée'
                  : null,
              onChanged: (c) => setState(() => _competenceId = c.id),
            ),
            if (selected != null && selected.parcours == null && selected.parcoursPossibles.length > 1)
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(
                    "Indiquez d'abord si vous avez appris cette compétence à l'école (secteur formel) ou sur le terrain (secteur informel).",
                    style: text.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Préciser le secteur',
                    variant: AppButtonVariant.secondary,
                    onPressed: () => context.push('/competences/${selected.id}'),
                  ),
                ]),
              ),
            if (selected?.parcours == Parcours.informel ||
                (selected?.parcours == null && selected?.parcoursPossibles.length == 1 && selected?.parcoursPossibles.first == Parcours.informel))
              AppCard(
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Text(
                    "Secteur informel : joignez le certificat délivré par un centre professionnel. Pas de certificat ? Vous pouvez passer un test de validation dans un centre.",
                    style: text.bodySmall?.copyWith(color: AppColors.muted),
                  ),
                  const SizedBox(height: 10),
                  AppButton(
                    label: 'Passer un test au centre',
                    variant: AppButtonVariant.secondary,
                    onPressed: busy ? null : () => context.push('/validations/demander?competenceId=${selected!.id}&test=1'),
                  ),
                ]),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Type de preuve',
                  style: text.bodySmall?.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 8),
                if (selected == null)
                  Text("Choisissez d'abord la compétence.", style: text.bodySmall?.copyWith(color: AppColors.muted)),
                if (types.isNotEmpty)
                  ProgressiveChoice<PreuveType>(
                    key: ValueKey(selected?.id),
                    options: types,
                    selected: _type,
                    enabled: !busy,
                    titleOf: (t) => t.label,
                    descriptionOf: (t) => t.description,
                    onChanged: (t) => setState(() => _type = t),
                  ),
                if (_showErrors && _type == null)
                  Text(
                    'Choisissez le type de preuve',
                    style: text.bodySmall?.copyWith(color: AppColors.error),
                  ),
              ],
            ),
            FilePickerField(
              label: 'Ajouter le fichier de la preuve',
              allowed: const {MediaKind.image, MediaKind.document},
              value: _media,
              enabled: !busy,
              uploadProgress: busy ? progress : null,
              errorText: _showErrors && _media == null
                  ? 'Ajoutez la photo ou le document'
                  : null,
              onChanged: (m) => setState(() => _media = m),
            ),
          ],
        );
      },
    );
  }
}
