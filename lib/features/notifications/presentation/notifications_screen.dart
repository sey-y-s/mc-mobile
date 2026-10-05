import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/paginated_list_view.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';
import 'package:mlc_mobile/features/notifications/presentation/notification_providers.dart';

/// Écran principal des notifications reçues par le citoyen.
/// Liste paginée avec distinction visuelle des non lues, marquage comme lu
/// et action globale « Tout marquer comme lu ».
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconForType(NotificationType type) {
    return switch (type) {
      NotificationType.miseEnRelation => AppIcons.relations,
      NotificationType.validation => AppIcons.validations,
      NotificationType.opportunite => AppIcons.opportunites,
      NotificationType.rappel => AppIcons.competences,
      NotificationType.systeme => AppIcons.passport,
      NotificationType.autre => AppIcons.notifications,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final revision = ref.watch(notificationsRevisionProvider);
    final unreadAsync = ref.watch(unreadNotificationCountProvider);
    final unreadCount = unreadAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Alertes & Notifications'),
            if (unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldSoft,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.goldDeep.withAlpha(51)),
                ),
                child: Text(
                  '$unreadCount',
                  style: const TextStyle(
                    color: AppColors.goldDeep,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          if (unreadCount > 0)
            IconButton(
              icon: const Icon(AppIcons.markAllRead),
              tooltip: 'Tout marquer comme lu',
              onPressed: () async {
                final ok = await ref
                    .read(notificationsControllerProvider.notifier)
                    .markAllAsRead();
                if (ok && context.mounted) {
                  showSuccessSnackBar(
                      context, 'Toutes les notifications sont marquées comme lues');
                }
              },
            ),
        ],
      ),
      body: PaginatedListView<AppNotification>(
        key: ValueKey(revision),
        pageSize: 20,
        emptyMessage: 'Aucune notification pour le moment.',
        fetchPage: (page, size) =>
            ref.read(notificationRepositoryProvider).list(page: page, size: size),
        itemBuilder: (context, item) {
          final isUnread = !item.lu;
          return AppCard(
            accentColor: isUnread ? AppColors.gold : null,
            onTap: () => context.push('/notifications/${item.id}'),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isUnread ? AppColors.goldSoft : AppColors.greenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _iconForType(item.type),
                    color: isUnread ? AppColors.goldDeep : AppColors.green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.titre,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isUnread
                                    ? AppColors.anthracite
                                    : AppColors.anthracite.withAlpha(204),
                              ),
                            ),
                          ),
                          if (isUnread) ...[
                            const SizedBox(width: 6),
                            const Icon(
                              AppIcons.unreadDot,
                              size: 10,
                              color: AppColors.goldDeep,
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.message,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatDateFr(item.dateCreation),
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                          ),
                          StatusBadge(
                            label: item.type.label,
                            tone: isUnread
                                ? BadgeTone.accent
                                : BadgeTone.neutral,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
