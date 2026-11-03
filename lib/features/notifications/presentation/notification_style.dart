import 'package:flutter/material.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';

/// Icône, couleur et ton de badge propres à chaque type de notification.
extension NotificationTypeStyle on NotificationType {
  IconData get icon => switch (this) {
    NotificationType.miseEnRelation => AppIcons.relations,
    NotificationType.validation => AppIcons.validations,
    NotificationType.opportunite => AppIcons.opportunites,
    NotificationType.besoinCompetence => AppIcons.competences,
    NotificationType.systeme => AppIcons.passport,
  };

  Color get color => switch (this) {
    NotificationType.miseEnRelation => const Color(0xFF1F6F8B),
    NotificationType.validation => AppColors.green,
    NotificationType.opportunite => AppColors.goldDeep,
    NotificationType.besoinCompetence => const Color(0xFF7A4E9C),
    NotificationType.systeme => AppColors.muted,
  };

  Color get softColor => color.withValues(alpha: 0.12);

  BadgeTone get tone => switch (this) {
    NotificationType.validation => BadgeTone.success,
    NotificationType.opportunite => BadgeTone.accent,
    _ => BadgeTone.neutral,
  };
}

/// Pastille compacte du type : elle prend la largeur de son texte, jamais celle de l'écran.
class NotificationTypeChip extends StatelessWidget {
  const NotificationTypeChip({super.key, required this.type});
  final NotificationType type;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: type.softColor,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(type.icon, size: 13, color: type.color),
        const SizedBox(width: 5),
        Text(
          type.label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: type.color, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}
