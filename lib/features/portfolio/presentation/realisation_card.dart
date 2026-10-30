import 'package:flutter/material.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/features/portfolio/presentation/portfolio_media_preview.dart';

/// Une réalisation du portfolio d'un autre citoyen (réponse du serveur), avec ses médias protégés.
class RealisationCard extends StatelessWidget {
  const RealisationCard({super.key, required this.r});
  final Map<String, dynamic> r;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final medias = (r['medias'] is List ? r['medias'] as List : const [])
        .whereType<Map>()
        .toList();
    final description = r['description']?.toString() ?? '';
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            (r['titre'] ?? 'Réalisation').toString(),
            style: text.titleMedium,
          ),
          if (r['dateRealisation'] != null || r['localisation'] != null)
            Text(
              [
                r['dateRealisation'],
                r['localisation'],
              ].where((e) => e != null).join(' · '),
              style: text.bodySmall?.copyWith(color: AppColors.muted),
            ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(description),
          ],
          for (final m in medias) ...[
            const SizedBox(height: 10),
            if (m['type']?.toString() == 'IMAGE')
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: PortfolioMediaPreview(
                  url: (m['urlMedia'] ?? '').toString(),
                  height: 200,
                  width: double.infinity,
                  cacheWidth: 800,
                ),
              )
            else
              Text(
                '${m['type'] ?? 'Média'} : ${m['legende'] ?? (m['urlMedia'] ?? '').toString().split('/').last}',
                style: text.bodySmall,
              ),
          ],
        ],
      ),
    );
  }
}
