import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/widgets/app_button.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/info_row.dart';
import 'package:mlc_mobile/core/widgets/state_views.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';
import 'package:mlc_mobile/features/notifications/presentation/notification_providers.dart';

/// Écran de consultation détaillée d'une notification.
/// À l'ouverture, marque la notification comme lue et propose une action contextuelle.
class NotificationDetailScreen extends ConsumerStatefulWidget {
  const NotificationDetailScreen({super.key, this.id});
  final String? id;

  @override
  ConsumerState<NotificationDetailScreen> createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState
    extends ConsumerState<NotificationDetailScreen> {
  bool _markedRead = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _triggerMarkAsRead();
  }

  void _triggerMarkAsRead() {
    final notifId = widget.id;
    if (notifId != null && notifId.isNotEmpty && !_markedRead) {
      _markedRead = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(notificationsControllerProvider.notifier)
              .markAsRead(notifId);
        }
      });
    }
  }

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

  Widget? _buildActionButton(BuildContext context, AppNotification notif) {
    final refId = notif.referenceId;
    return switch (notif.type) {
      NotificationType.miseEnRelation => AppButton(
          label: 'Voir la mise en relation',
          icon: AppIcons.relations,
          onPressed: () {
            if (refId != null && refId.isNotEmpty) {
              context.push('/relations/$refId');
            } else {
              context.push('/relations');
            }
          },
        ),
      NotificationType.validation => AppButton(
          label: 'Voir la validation',
          icon: AppIcons.validations,
          onPressed: () {
            if (refId != null && refId.isNotEmpty) {
              context.push('/validations/$refId');
            } else {
              context.push('/validations');
            }
          },
        ),
      NotificationType.opportunite => AppButton(
          label: 'Découvrir l\'opportunité',
          icon: AppIcons.opportunites,
          onPressed: () {
            if (refId != null && refId.isNotEmpty) {
              context.push('/opportunites/$refId');
            } else {
              context.push('/opportunites');
            }
          },
        ),
      NotificationType.rappel => AppButton(
          label: 'Ouvrir mon passeport',
          icon: AppIcons.passport,
          onPressed: () => context.push('/passeport'),
        ),
      NotificationType.systeme => AppButton(
          label: 'Consulter les tests',
          icon: AppIcons.tests,
          onPressed: () => context.push('/tests'),
        ),
      NotificationType.autre => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final notifId = widget.id;
    if (notifId == null || notifId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Notification')),
        body: const ErrorView(error: NotFoundFailure('Identifiant manquant.')),
      );
    }

    final notifAsync = ref.watch(notificationDetailProvider(notifId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification'),
      ),
      body: AsyncValueView<AppNotification>(
        value: notifAsync,
        onRetry: () => ref.invalidate(notificationDetailProvider(notifId)),
        data: (notif) {
          final actionButton = _buildActionButton(context, notif);

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.greenSoft,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      _iconForType(notif.type),
                      color: AppColors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          notif.titre,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        StatusBadge(
                          label: notif.type.label,
                          tone: BadgeTone.accent,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              AppCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Message',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppColors.muted,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      notif.message,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: AppColors.anthracite,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    InfoRow(
                      icon: AppIcons.calendar,
                      label: 'Date de réception',
                      value: formatDateFr(notif.dateCreation),
                    ),
                    if (notif.destinataire?.dateLecture != null)
                      InfoRow(
                        icon: AppIcons.selected,
                        label: 'Lue le',
                        value: formatDateFr(notif.destinataire!.dateLecture!),
                      ),
                    if (notif.referenceId != null)
                      InfoRow(
                        icon: AppIcons.visible,
                        label: 'Référence',
                        value: notif.referenceId!,
                      ),
                  ],
                ),
              ),
              if (actionButton != null) ...[
                const SizedBox(height: 28),
                actionButton,
              ],
            ],
          );
        },
      ),
    );
  }
}
