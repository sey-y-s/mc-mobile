import 'package:flutter/material.dart';
import 'package:mlc_mobile/app/theme/app_colors.dart';

class AppNavItem {
  const AppNavItem({required this.label, required this.icon, required this.activeIcon});
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

/// Barre de navigation : fond blanc, trait fin, onglet actif = icône pleine verte + filet or.
/// Libellés toujours visibles (lisibilité avant tout).
class AppNavBar extends StatelessWidget {
  const AppNavBar({super.key, required this.items, required this.currentIndex, required this.onTap});
  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: AppColors.card, border: Border(top: BorderSide(color: AppColors.border))),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(children: [
            for (var i = 0; i < items.length; i++)
              Expanded(child: _Item(item: items[i], selected: i == currentIndex, onTap: () => onTap(i))),
          ]),
        ),
      ),
    );
  }
}

class _Item extends StatelessWidget {
  const _Item({required this.item, required this.selected, required this.onTap});
  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.green : AppColors.muted;
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        highlightShape: BoxShape.rectangle,
        child: Stack(alignment: Alignment.topCenter, children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: selected ? 28 : 0,
            height: 3,
            decoration: const BoxDecoration(
              color: AppColors.gold,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(3)),
            ),
          ),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(selected ? item.activeIcon : item.icon, color: color, size: 24),
              const SizedBox(height: 3),
              Text(item.label, style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.w500 : FontWeight.w400)),
            ]),
          ),
        ]),
      ),
    );
  }
}
