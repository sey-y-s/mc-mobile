import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/app_nav_bar.dart';

/// Navigation principale (5 onglets) : Accueil, Passeport, Talents, Alertes, Plus.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  static const _tabs = <(AppNavItem, String)>[
    (AppNavItem(label: 'Accueil', icon: AppIcons.home, activeIcon: AppIcons.homeActive), '/home'),
    (AppNavItem(label: 'Passeport', icon: AppIcons.passport, activeIcon: AppIcons.passportActive), '/passeport'),
    (AppNavItem(label: 'Talents', icon: AppIcons.talents, activeIcon: AppIcons.talentsActive), '/talents'),
    (AppNavItem(label: 'Alertes', icon: AppIcons.notifications, activeIcon: AppIcons.notificationsActive), '/notifications'),
    (AppNavItem(label: 'Plus', icon: AppIcons.more, activeIcon: AppIcons.moreActive), '/parametres'),
  ];

  @override
  Widget build(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    final index = _tabs.indexWhere((t) => path.startsWith(t.$2));
    return Scaffold(
      body: child,
      bottomNavigationBar: AppNavBar(
        items: [for (final t in _tabs) t.$1],
        currentIndex: index < 0 ? 0 : index,
        onTap: (i) => context.go(_tabs[i].$2),
      ),
    );
  }
}
