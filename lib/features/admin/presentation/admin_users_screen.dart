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

class AdminUsersScreen extends ConsumerWidget {
  const AdminUsersScreen({super.key});

  static const _roles = [
    'CITOYEN',
    'ORGANISATION',
    'EVALUATEUR',
    'ADMIN',
    'SUPER_ADMIN',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allowed = ref.watch(isSuperAdminProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Comptes et rôles')),
      body: allowed.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(isSuperAdminProvider),
        ),
        data: (isAllowed) => isAllowed
            ? _usersContent(context, ref)
            : const ErrorView(error: ForbiddenFailure()),
      ),
    );
  }

  Widget _usersContent(BuildContext context, WidgetRef ref) {
    final users = ref.watch(adminUsersProvider);
    final currentUser = ref.watch(currentUserIdProvider);
    final currentUserId = currentUser.value;
    return users.when(
      loading: () => const LoadingView(),
      error: (error, _) => ErrorView(
        error: error,
        onRetry: () => ref.invalidate(adminUsersProvider),
      ),
      data: (items) => RefreshIndicator(
        onRefresh: () => ref.refresh(adminUsersProvider.future),
        child: items.isEmpty
            ? const EmptyView(message: 'Aucun compte à afficher.')
            : ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final user = items[index];
                  final isCurrentUser = currentUserId == user.id;
                  return AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.email?.isNotEmpty == true
                              ? user.email!
                              : (user.telephone ?? 'Compte'),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.actif ? 'Compte actif' : 'Compte désactivé',
                          style: const TextStyle(color: AppColors.muted),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _roles.contains(user.role) ? user.role : null,
                          decoration: const InputDecoration(
                            labelText: 'Rôle',
                            prefixIcon: Icon(Icons.admin_panel_settings_outlined),
                          ),
                          items: [
                            for (final role in _roles)
                              DropdownMenuItem(
                                value: role,
                                child: Text(_roleLabel(role)),
                              ),
                          ],
                          onChanged: isCurrentUser || !currentUser.hasValue
                              ? null
                              : (role) {
                                  if (role != null && role != user.role) {
                                    _updateRole(context, ref, user, role);
                                  }
                                },
                        ),
                        if (isCurrentUser || !currentUser.hasValue)
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              isCurrentUser
                                  ? 'Votre propre rôle ne peut pas être modifié ici.'
                                  : 'Vérification de la session en cours…',
                              style: const TextStyle(
                                color: AppColors.muted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _updateRole(
    BuildContext context,
    WidgetRef ref,
    AdminUser user,
    String role,
  ) async {
    final confirmed = await confirmDialog(
      context,
      title: 'Modifier le rôle ?',
      message:
          'Le compte recevra les permissions « ${_roleLabel(role)} ». Cette action est immédiate.',
      confirmLabel: 'Modifier le rôle',
    );
    if (!confirmed) {
      ref.invalidate(adminUsersProvider);
      return;
    }
    if (!context.mounted) return;
    try {
      await ref.read(apiAdminRepositoryProvider).updateUserRole(user.id, role);
      ref.invalidate(adminUsersProvider);
      showSuccess(context, 'Rôle mis à jour');
    } catch (error) {
      ref.invalidate(adminUsersProvider);
      if (context.mounted) showError(context, failureMessage(error));
    }
  }

  static String _roleLabel(String role) => switch (role) {
    'CITOYEN' => 'Citoyen',
    'ORGANISATION' => 'Organisation',
    'EVALUATEUR' => 'Évaluateur',
    'ADMIN' => 'Administrateur',
    'SUPER_ADMIN' => 'Super-administrateur',
    _ => role,
  };
}
