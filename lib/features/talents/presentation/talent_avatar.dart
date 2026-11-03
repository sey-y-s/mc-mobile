import 'package:flutter/material.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/features/portfolio/presentation/portfolio_media_preview.dart';

/// Photo d'un contact établi (chargée avec le jeton de connexion) ; silhouette pour un profil anonyme.
class TalentAvatar extends StatelessWidget {
  const TalentAvatar({super.key, this.photoUrl, this.radius = 21});
  final String? photoUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    if (url == null || url.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.greenSoft,
        child: Icon(AppIcons.person, color: AppColors.green, size: radius * 1.1),
      );
    }
    return ClipOval(
      child: PortfolioMediaPreview(url: url, width: radius * 2, height: radius * 2, cacheWidth: 200),
    );
  }
}
