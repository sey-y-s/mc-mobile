import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/utils/date_format.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/filter_chips.dart';
import 'package:mlc_mobile/core/widgets/paginated_list_view.dart';
import 'package:mlc_mobile/core/widgets/status_badge.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_models.dart';
import 'package:mlc_mobile/features/opportunites/presentation/opportunite_providers.dart';

/// Liste paginée des opportunités en lecture seule, filtrable par type.
class OpportunitesListScreen extends ConsumerWidget {
  const OpportunitesListScreen({super.key});

  BadgeTone _toneForType(OpportuniteType type) {
    return switch (type) {
      OpportuniteType.formationGratuite => BadgeTone.success,
      OpportuniteType.bourse => BadgeTone.accent,
      OpportuniteType.programme => BadgeTone.accent,
      OpportuniteType.concours => BadgeTone.success,
      _ => BadgeTone.neutral,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedType = ref.watch(opportuniteTypeFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Opportunités'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: FilterChips<OpportuniteType>(
              options: OpportuniteType.values,
              labelOf: (t) => t.label,
              selected: selectedType,
              allLabel: 'Toutes',
              onChanged: (t) {
                ref.read(opportuniteTypeFilterProvider.notifier).state = t;
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: PaginatedListView<Opportunite>(
              key: ValueKey(selectedType),
              pageSize: 20,
              emptyMessage:
                  'Aucune opportunité disponible dans cette catégorie pour le moment.',
              fetchPage: (page, size) => ref
                  .read(opportuniteRepositoryProvider)
                  .list(type: selectedType, page: page, size: size),
              itemBuilder: (context, item) {
                final isUrgent = item.expirationDate != null &&
                    item.expirationDate!
                        .difference(DateTime.now())
                        .inDays <=
                        5;

                return AppCard(
                  onTap: () => context.push('/opportunites/${item.id}'),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          StatusBadge(
                            label: item.type.label,
                            tone: _toneForType(item.type),
                          ),
                          if (item.categoryName != null) ...[
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item.categoryName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.muted,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        item.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: AppColors.anthracite,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          if (item.expirationDate != null) ...[
                            Icon(
                              AppIcons.calendar,
                              size: 15,
                              color: isUrgent
                                  ? AppColors.error
                                  : AppColors.muted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Expire le ${formatDateFr(item.expirationDate!)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isUrgent
                                    ? AppColors.error
                                    : AppColors.muted,
                                fontWeight: isUrgent
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ] else ...[
                            Text(
                              'Publié le ${formatDateFr(item.publishedAt)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                          const Spacer(),
                          const Icon(
                            AppIcons.chevron,
                            size: 18,
                            color: AppColors.muted,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
