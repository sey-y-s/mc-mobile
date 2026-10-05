import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/section_header.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';
import 'package:mlc_mobile/features/notifications/presentation/notification_providers.dart';

/// Bloc « Dernières notifications » affiché sur la page d'accueil.
class NotificationsBlock extends ConsumerWidget {
  const NotificationsBlock({super.key});

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
    final notifsAsync = ref.watch(recentNotificationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Dernières notifications',
          actionLabel: 'Voir tout',
          onAction: () => context.push('/notifications'),
        ),
        notifsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    failureMessage(e),
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(recentNotificationsProvider),
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return AppCard(
                child: Row(
                  children: [
                    const Icon(AppIcons.notifications,
                        color: AppColors.muted, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Aucune nouvelle notification.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                for (final notif in items) ...[
                  AppCard(
                    accentColor: !notif.lu ? AppColors.gold : null,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    onTap: () => context.push('/notifications/${notif.id}'),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: !notif.lu
                                ? AppColors.goldSoft
                                : AppColors.greenSoft,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _iconForType(notif.type),
                            size: 18,
                            color:
                                !notif.lu ? AppColors.goldDeep : AppColors.green,
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
                                      notif.titre,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: !notif.lu
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (!notif.lu) ...[
                                    const SizedBox(width: 6),
                                    const Icon(
                                      AppIcons.unreadDot,
                                      size: 8,
                                      color: AppColors.goldDeep,
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatDateFr(notif.dateCreation),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(AppIcons.chevron,
                            size: 16, color: AppColors.muted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}
