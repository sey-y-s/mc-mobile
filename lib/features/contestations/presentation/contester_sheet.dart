import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/progressive_choice.dart';
import 'package:mlc_mobile/features/contestations/data/contestation_repository.dart';
import 'package:mlc_mobile/features/contestations/presentation/contestation_providers.dart';

/// Formulaire de contestation / correction, en feuille du bas.
/// [validationId] fourni : contestation d'une décision. Sinon : correction d'une information du profil.
Future<bool?> ouvrirContestation(
  BuildContext context, {
  String? validationId,
  String? competenceNom,
}) => showModalBottomSheet<bool>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
    child: _ContesterForm(
      validationId: validationId,
      competenceNom: competenceNom,
    ),
  ),
);

class _ContesterForm extends ConsumerStatefulWidget {
  const _ContesterForm({this.validationId, this.competenceNom});
  final String? validationId;
  final String? competenceNom;

  @override
  ConsumerState<_ContesterForm> createState() => _ContesterFormState();
}

class _ContesterFormState extends ConsumerState<_ContesterForm> {
  final _motif = TextEditingController();
  (String, String)? _champ;
  bool _busy = false;
  String? _erreur;

  bool get _decision => widget.validationId != null;

  @override
  void dispose() {
    _motif.dispose();
    super.dispose();
  }

  Future<void> _envoyer() async {
    if (!_decision && _champ == null) {
      setState(() => _erreur = 'Choisissez l’information à corriger.');
      return;
    }
    if (_motif.text.trim().length < 10) {
      setState(
        () => _erreur =
            'Expliquez votre demande en quelques mots (10 caractères minimum).',
      );
      return;
    }
    setState(() {
      _busy = true;
      _erreur = null;
    });
    try {
      await ref
          .read(contestationRepositoryProvider)
          .creer(
            objet: _decision
                ? ObjetContestation.decision
                : ObjetContestation.profil,
            motif: _motif.text.trim(),
            validationId: widget.validationId,
            champConcerne: _decision ? null : _champ!.$1,
          );
      ref.invalidate(mesContestationsProvider);
      if (mounted) {
        showSuccess(
          context,
          'Demande envoyée. Vous serez prévenu de la réponse.',
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() => _erreur = e is AppFailure ? e.message : failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _decision
                  ? 'Contester cette décision'
                  : 'Demander une correction',
              style: text.titleLarge,
            ),
            const SizedBox(height: 6),
            Text(
              _decision
                  ? 'La décision${widget.competenceNom != null ? ' sur « ${widget.competenceNom} »' : ''} sera réexaminée. '
                        'Si votre demande est acceptée, une nouvelle décision est enregistrée ; l’ancienne reste dans votre historique.'
                  : 'Une information de votre profil est inexacte ? Indiquez laquelle : l’administration la vérifiera.',
              style: text.bodySmall?.copyWith(color: AppColors.muted),
            ),
            const SizedBox(height: 16),
            if (!_decision) ...[
              ProgressiveChoice<(String, String)>(
                options: champsProfil,
                selected: _champ,
                enabled: !_busy,
                titleOf: (c) => c.$2,
                changeLabel: 'Choisir une autre information',
                onChanged: (c) => setState(() => _champ = c),
              ),
              const SizedBox(height: 8),
            ],
            TextField(
              controller: _motif,
              enabled: !_busy,
              minLines: 3,
              maxLines: 6,
              maxLength: 2000,
              decoration: InputDecoration(
                labelText: _decision
                    ? 'Pourquoi contestez-vous ?'
                    : 'Quelle est la bonne information ?',
                alignLabelWithHint: true,
              ),
            ),
            if (_erreur != null) ...[
              Text(_erreur!, style: const TextStyle(color: AppColors.error)),
              const SizedBox(height: 8),
            ],
            const SizedBox(height: 8),
            AppButton(
              label: 'Envoyer ma demande',
              isLoading: _busy,
              onPressed: _envoyer,
            ),
          ],
        ),
      ),
    );
  }
}
