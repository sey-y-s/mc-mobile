import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/media/ouvrir_fichier.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_dialogs.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/features/admin/domain/admin_models.dart';
import 'package:mlc_mobile/features/admin/presentation/admin_providers.dart';
import 'package:mlc_mobile/features/validations/domain/validation_models.dart';

class AdminValidationsScreen extends ConsumerStatefulWidget {
  const AdminValidationsScreen({super.key});

  @override
  ConsumerState<AdminValidationsScreen> createState() =>
      _AdminValidationsScreenState();
}

class _AdminValidationsScreenState
    extends ConsumerState<AdminValidationsScreen> {
  String? _status;
  ValidationType? _type;
  bool _busy = false;

  /// Justificatifs ouverts : on n'approuve qu'une pièce que l'on a vérifiée.
  final Set<String> _vus = {};

  static const _statuses = <String, String>{
    'EN_ATTENTE': 'En attente',
    'APPROUVEE': 'Approuvées',
    'REJETEE': 'Rejetées',
  };
  static const _types = <ValidationType>[
    ValidationType.diplomeVerifie,
    ValidationType.partenaireAtteste,
    ValidationType.validationPratique,
    ValidationType.testNumerique,
    ValidationType.vae,
  ];

  @override
  Widget build(BuildContext context) {
    final validations = ref.watch(adminValidationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Demandes de validation')),
      body: Column(
        children: [
          _filterRow(
            label: 'Statut',
            chips: [
              _statusChip(null, 'Tous'),
              for (final entry in _statuses.entries)
                _statusChip(entry.key, entry.value),
            ],
          ),
          _filterRow(
            label: 'Type de validation',
            chips: [
              _typeChip(null, 'Tous'),
              for (final type in _types) _typeChip(type, type.label),
            ],
          ),
          Expanded(
            child: validations.when(
              loading: () => const LoadingView(),
              error: (error, _) => ErrorView(
                error: error,
                onRetry: () => ref.invalidate(adminValidationsProvider),
              ),
              data: (items) {
                final filtered = items
                    .where(
                      (item) =>
                          (_status == null || item.status == _status) &&
                          (_type == null || item.type == _type!.apiCode),
                    )
                    .toList();
                return RefreshIndicator(
                  onRefresh: () => ref.refresh(adminValidationsProvider.future),
                  child: filtered.isEmpty
                      ? const EmptyView(
                          message: 'Aucune demande pour ce statut.',
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          itemCount: filtered.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 10),
                          itemBuilder: (context, index) =>
                              _validationCard(context, filtered[index]),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterRow({required String label, required List<Widget> chips}) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.muted,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(children: chips),
          ),
        ],
      );

  Widget _statusChip(String? value, String label) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _status == value,
      onSelected: (_) => setState(() => _status = value),
    ),
  );

  Widget _typeChip(ValidationType? value, String label) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(label),
      selected: _type == value,
      onSelected: (_) => setState(() => _type = value),
    ),
  );

  Widget _validationCard(BuildContext context, AdminValidation item) {
    // Une évaluation faite par un centre est décidée par son évaluateur ; l'administrateur tranche
    // les validations documentaires (sans centre).
    final decidable = item.status == 'EN_ATTENTE' && item.centreName == null;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.label.isEmpty ? 'Validation ${item.id}' : item.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          Text(
            '${_typeLabel(item.type)} · ${_statuses[item.status] ?? item.status}',
            style: const TextStyle(color: AppColors.muted),
          ),
          if (item.centreName != null)
            Text(
              'Centre : ${item.centreName}',
              style: const TextStyle(color: AppColors.muted),
            ),
          if (item.comment != null && item.comment!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Commentaire : ${item.comment}'),
            ),
          if (item.proofUrl != null) ...[
            const SizedBox(height: 8),
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
              onPressed: () => _ouvrirPreuve(item),
              icon: const Icon(Icons.description_outlined, size: 18),
              label: Text(
                item.proofTitle ?? 'Voir le justificatif',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (decidable && item.proofUrl != null && !_vus.contains(item.id))
            const Padding(
              padding: EdgeInsets.only(top: 6),
              child: Text(
                'Ouvrez le justificatif pour pouvoir approuver.',
                style: TextStyle(color: AppColors.muted, fontSize: 12),
              ),
            ),
          if (decidable) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                    ),
                    onPressed:
                        _busy ||
                            (item.proofUrl != null && !_vus.contains(item.id))
                        ? null
                        : () => _decider(item, 'APPROUVEE'),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Approuver'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    onPressed: _busy ? null : () => _decider(item, 'REJETEE'),
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

  Future<void> _ouvrirPreuve(AdminValidation item) async {
    try {
      await ouvrirFichierProtege(ref, item.proofUrl!, nom: item.proofTitle);
      if (mounted) setState(() => _vus.add(item.id));
    } catch (e) {
      if (mounted) showError(context, failureMessage(e));
    }
  }

  Future<void> _decider(AdminValidation item, String statut) async {
    String? commentaire;
    if (statut == 'REJETEE') {
      commentaire = await _demanderMotif();
      if (commentaire == null) return;
    } else {
      final ok = await confirmDialog(
        context,
        title: 'Approuver cette validation ?',
        message: 'La compétence sera marquée comme validée et le citoyen sera prévenu.',
        confirmLabel: 'Approuver',
      );
      if (!ok) return;
    }
    setState(() => _busy = true);
    try {
      await ref
          .read(apiAdminRepositoryProvider)
          .updateValidationStatus(
            item.id,
            status: statut,
            comment: commentaire,
          );
      ref.invalidate(adminValidationsProvider);
      if (mounted) {
        showSuccess(
          context,
          statut == 'APPROUVEE' ? 'Validation approuvée.' : 'Demande refusée.',
        );
      }
    } catch (e) {
      if (mounted) showError(context, failureMessage(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Le serveur exige un motif pour refuser : il est transmis au citoyen.
  Future<String?> _demanderMotif() async {
    final controller = TextEditingController();
    final motif = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Motif du refus'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          maxLength: 500,
          decoration: const InputDecoration(
            labelText: 'Expliquez brièvement pourquoi',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () {
              final t = controller.text.trim();
              if (t.isNotEmpty) Navigator.pop(ctx, t);
            },
            child: const Text('Refuser'),
          ),
        ],
      ),
    );
    controller.dispose();
    return motif;
  }

  static String _typeLabel(String type) => switch (type) {
    'DIPLOME_VERIFIE' => 'Diplôme vérifié',
    'PARTENAIRE_ATTESTE' => 'Attestation de partenaire',
    'VALIDATION_PRATIQUE' => 'Évaluation pratique',
    'PORTFOLIO_MEDIA' => 'Évaluation sur portfolio',
    'MAITRE_ARTISAN' => 'Évaluation par un maître artisan',
    'TEST_NUMERIQUE' => 'Test numérique',
    'VAE' => 'Validation des acquis',
    _ => type,
  };
}
