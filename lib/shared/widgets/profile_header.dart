import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/core/media/secure_image.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/utils/snackbars.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';

/// En-tête de profil. Mode [anonymized] : aucune photo ni identité (recherche de talents).
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader(
      {super.key,
      required this.title,
      this.subtitle,
      this.codePasseport,
      this.avatarUrl,
      this.anonymized = false,
      this.onAvatarTap,
      this.onSubtitleTap});
  final String title;
  final String? subtitle;
  final String? codePasseport;
  final String? avatarUrl;
  final bool anonymized;

  /// Toucher la photo (ex. ouvrir l'écran pour l'ajouter ou la changer).
  final VoidCallback? onAvatarTap;

  /// Toucher la localisation (ex. ouvrir le choix de la commune).
  final VoidCallback? onSubtitleTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = Theme.of(context).textTheme;
    // La photo est un fichier privé du serveur : chargée avec le jeton de connexion.
    final photo = anonymized ? null : imageDepuisUrl(ref, avatarUrl);
    return Row(children: [
      Semantics(
        button: onAvatarTap != null,
        label: photo == null ? 'Ajouter une photo de profil' : 'Changer la photo de profil',
        child: GestureDetector(
          onTap: onAvatarTap,
          child: Stack(clipBehavior: Clip.none, children: [
            Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 2)),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.greenSoft,
                foregroundImage: photo,
                onForegroundImageError: photo == null ? null : (_, _) {},
                child: const Icon(AppIcons.person, color: AppColors.green, size: 30),
              ),
            ),
            if (onAvatarTap != null)
              Positioned(
                right: -2,
                bottom: -2,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: AppColors.green,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(photo == null ? Icons.add_a_photo_outlined : Icons.edit, size: 14, color: Colors.white),
                ),
              ),
          ]),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(anonymized ? 'Profil anonymisé' : title,
              style: text.headlineSmall),
          if (subtitle != null)
            InkWell(
              onTap: onSubtitleTap,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (onSubtitleTap != null) ...[
                    const Icon(Icons.place_outlined, size: 16, color: AppColors.muted),
                    const SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(subtitle!,
                        style: text.bodyMedium?.copyWith(
                            color: AppColors.muted,
                            decoration: onSubtitleTap != null ? TextDecoration.underline : null)),
                  ),
                ]),
              ),
            ),
          if (!anonymized && codePasseport != null)
            Row(children: [
              Flexible(
                child: Text('Code : $codePasseport',
                    overflow: TextOverflow.ellipsis,
                    style: text.labelMedium?.copyWith(color: AppColors.goldDeep)),
              ),
              IconButton(
                tooltip: 'Copier le code',
                icon: const Icon(AppIcons.copy, size: 18),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: codePasseport!));
                  if (context.mounted) showSuccess(context, 'Code copié');
                },
              ),
            ]),
        ]),
      ),
    ]);
  }
}
