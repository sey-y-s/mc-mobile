import 'package:flutter/material.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/app/theme/app_theme.dart';

/// Carte sans ombre : fond blanc + trait fin.
/// [accentColor] ajoute un liseré à gauche qui porte une information (ex. état d'une compétence).
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(16),
    this.accentColor,
  });
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(AppRadius.card);
    final content = Padding(padding: padding, child: child);
    final card = Material(
      color: AppColors.card,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.border),
        ),
        child: InkWell(
          onTap: onTap,
          child: accentColor == null
              ? content
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(width: 4, color: accentColor),
                      Expanded(child: content),
                    ],
                  ),
                ),
        ),
      ),
    );
    if (MediaQuery.maybeOf(context)?.disableAnimations ?? false) return card;
    // Apparition douce de chaque carte à son arrivée à l'écran.
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 10 * (1 - t)), child: c),
      ),
      child: card,
    );
  }
}
