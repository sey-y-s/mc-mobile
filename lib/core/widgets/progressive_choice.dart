import 'package:flutter/material.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';
import 'package:mlc_mobile/core/widgets/selectable_option_card.dart';

/// Choix unique « progressif » : tant que rien n'est choisi, toutes les options s'affichent ;
/// dès qu'une option est choisie, les autres disparaissent (avec animation) et seul
/// le choix retenu reste visible, accompagné de ce qui le concerne ([detailsOf]).
/// Un lien « Changer » fait réapparaître les autres options.
///
/// S'il n'y a qu'une seule option possible, elle est présentée comme imposée
/// (pas de choix à faire) avec l'explication [singleNote].
class ProgressiveChoice<T> extends StatelessWidget {
  const ProgressiveChoice({
    super.key,
    required this.options,
    required this.selected,
    required this.onChanged,
    required this.titleOf,
    this.descriptionOf,
    this.detailsOf,
    this.singleNote,
    this.enabled = true,
    this.changeLabel = 'Changer',
  });

  final List<T> options;
  final T? selected;
  final ValueChanged<T?> onChanged;
  final String Function(T) titleOf;
  final String? Function(T)? descriptionOf;

  /// Contenu affiché sous l'option retenue (preuves attendues, actions…).
  final Widget? Function(T)? detailsOf;

  /// Explication affichée quand une seule option est possible.
  final String? singleNote;
  final bool enabled;
  final String changeLabel;

  static const _duree = Duration(milliseconds: 320);

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final unique = options.length == 1;
    final choisi = selected != null && options.contains(selected) ? selected : null;
    final visibles = choisi == null ? options : <T>[choisi];
    final reduit = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final duree = reduit ? Duration.zero : _duree;

    return AnimatedSize(
      duration: duree,
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (unique && singleNote != null) ...[
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline, size: 18, color: AppColors.muted),
              const SizedBox(width: 8),
              Expanded(child: Text(singleNote!, style: text.bodySmall?.copyWith(color: AppColors.muted))),
            ]),
            const SizedBox(height: 10),
          ],
          for (final (i, o) in visibles.indexed) ...[
            _Entree(
              key: ValueKey(o),
              index: choisi == null ? i : 0,
              duree: duree,
              child: SelectableOptionCard(
                title: titleOf(o),
                description: descriptionOf?.call(o),
                selected: choisi == o || unique,
                onTap: !enabled || unique
                    ? null
                    : () => onChanged(choisi == o ? null : o),
              ),
            ),
            const SizedBox(height: 10),
          ],
          AnimatedSwitcher(
            duration: duree,
            switchInCurve: Curves.easeOutCubic,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, .08), end: Offset.zero).animate(anim),
                child: child,
              ),
            ),
            child: choisi == null
                ? const SizedBox.shrink(key: ValueKey('vide'))
                : Column(
                    key: ValueKey(choisi),
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!unique)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: enabled ? () => onChanged(null) : null,
                            icon: const Icon(Icons.swap_horiz, size: 18),
                            label: Text(changeLabel),
                          ),
                        ),
                      ?detailsOf?.call(choisi),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Apparition en fondu + glissement, décalée selon la position dans la liste.
class _Entree extends StatelessWidget {
  const _Entree({super.key, required this.index, required this.duree, required this.child});
  final int index;
  final Duration duree;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (duree == Duration.zero) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duree + Duration(milliseconds: 70 * index),
      curve: Interval((70 * index) / (duree.inMilliseconds + 70 * index), 1, curve: Curves.easeOutCubic),
      builder: (context, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 14 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}
