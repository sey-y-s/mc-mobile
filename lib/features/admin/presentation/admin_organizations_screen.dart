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

class AdminOrganizationsScreen extends ConsumerWidget {
  const AdminOrganizationsScreen({super.key});

  static const _statuses = [
    'EN_ATTENTE',
    'APPROUVEE',
    'REJETEE',
    'SUSPENDUE',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final organizations = ref.watch(adminOrganizationsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Organisations')),
      body: organizations.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(adminOrganizationsProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () => ref.refresh(adminOrganizationsProvider.future),
          child: items.isEmpty
              ? const EmptyView(message: 'Aucune organisation enregistrée.')
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _OrganizationCard(item: items[index]),
                ),
        ),
      ),
    );
  }
}

class _OrganizationCard extends ConsumerWidget {
  const _OrganizationCard({required this.item});

  final AdminOrganization item;

  @override
  Widget build(BuildContext context, WidgetRef ref) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        if (item.email?.isNotEmpty == true) ...[
          const SizedBox(height: 4),
          Text(item.email!, style: const TextStyle(color: AppColors.muted)),
        ],
        if (item.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(item.description!),
        ],
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _OrganizationStatus.labels.containsKey(item.status)
              ? item.status
              : null,
          decoration: const InputDecoration(
            labelText: 'Statut',
            prefixIcon: Icon(Icons.verified_outlined),
          ),
          items: [
            for (final status in AdminOrganizationsScreen._statuses)
              DropdownMenuItem(
                value: status,
                child: Text(_OrganizationStatus.labels[status]!),
              ),
          ],
          onChanged: (status) {
            if (status != null && status != item.status) {
              _updateStatus(context, ref, status);
            }
          },
        ),
      ],
    ),
  );

  Future<void> _updateStatus(
    BuildContext context,
    WidgetRef ref,
    String status,
  ) async {
    final accepted = await confirmDialog(
      context,
      title: 'Modifier le statut ?',
      message:
          'Le statut de « ${item.name} » sera remplacé par ${_OrganizationStatus.labels[status]}.',
      confirmLabel: 'Confirmer',
    );
    if (!accepted) {
      ref.invalidate(adminOrganizationsProvider);
      return;
    }
    if (!context.mounted) return;
    try {
      await ref
          .read(apiAdminRepositoryProvider)
          .updateOrganizationStatus(item.id, status);
      ref.invalidate(adminOrganizationsProvider);
      showSuccess(context, 'Statut de l’organisation mis à jour');
    } catch (error) {
      ref.invalidate(adminOrganizationsProvider);
      if (context.mounted) showError(context, failureMessage(error));
    }
  }
}

class _OrganizationStatus {
  static const labels = {
    'EN_ATTENTE': 'En attente',
    'APPROUVEE': 'Approuvée',
    'REJETEE': 'Rejetée',
    'SUSPENDUE': 'Suspendue',
  };
}
