import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
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
                          (_type == null ||
                              item.type == _type!.apiCode),
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
              PopupMenuButton<String>(
                tooltip: 'Enregistrer une décision',
                onSelected: (status) => _decide(item, status),
                itemBuilder: (context) => [
                  for (final entry in _statuses.entries)
                    PopupMenuItem(
                      value: entry.key,
                      enabled: entry.key != item.status,
                      child: Text(entry.value),
                    ),
                ],
              ),
            ],
          ),
          Text(
            '${_typeLabel(item.type)} · ${_statuses[item.status] ?? item.status}',
            style: const TextStyle(color: AppColors.muted),
          ),
        ],
      ),
    );
  }

  Future<void> _decide(AdminValidation item, String status) async {
    String? comment;
    if (status == 'REJETEE') {
      final controller = TextEditingController();
      comment = await showDialog<String>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Motif du rejet'),
          content: TextField(
            controller: controller,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Commentaire à transmettre',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Continuer'),
            ),
          ],
        ),
      );
      controller.dispose();
      if (comment == null || !mounted) return;
      if (comment.trim().isEmpty) {
        showError(context, 'Indiquez le motif du rejet.');
        return;
      }
    } else {
      final accepted = await confirmDialog(
        context,
        title: 'Confirmer la décision ?',
        message:
            'La demande « ${item.label} » passera au statut ${_statuses[status]}.',
        confirmLabel: 'Confirmer',
      );
      if (!accepted || !mounted) return;
    }
    try {
      await ref
          .read(apiAdminRepositoryProvider)
          .updateValidationStatus(item.id, status: status, comment: comment);
      ref.invalidate(adminValidationsProvider);
      ref.invalidate(adminDashboardProvider);
      if (mounted) {
        showSuccess(context, 'Décision enregistrée');
      }
    } catch (error) {
      if (mounted) showError(context, failureMessage(error));
    }
  }

  static String _typeLabel(String type) => switch (type) {
    'DIPLOME_VERIFIE' => 'Diplôme vérifié',
    'PARTENAIRE_ATTESTE' => 'Attestation de partenaire',
    'VALIDATION_PRATIQUE' => 'Évaluation pratique',
    'TEST_NUMERIQUE' => 'Test numérique',
    'VAE' => 'Validation des acquis',
    _ => type,
  };
}
