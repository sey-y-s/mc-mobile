import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/core/widgets/app_nav_bar.dart';
import 'package:mlc_mobile/features/notifications/presentation/notification_providers.dart';

/// Navigation principale (5 onglets) : Accueil, Passeport, Talents, Alertes, Plus.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount =
        ref.watch(unreadNotificationCountProvider).value ?? 0;

    final tabs = <(AppNavItem, String)>[
      (
        const AppNavItem(
            label: 'Accueil',
            icon: AppIcons.home,
            activeIcon: AppIcons.homeActive),
        '/home'
      ),
      (
        const AppNavItem(
            label: 'Passeport',
            icon: AppIcons.passport,
            activeIcon: AppIcons.passportActive),
        '/passeport'
      ),
      (
        const AppNavItem(
            label: 'Talents',
            icon: AppIcons.talents,
            activeIcon: AppIcons.talentsActive),
        '/talents'
      ),
      (
        AppNavItem(
          label: 'Alertes',
          icon: AppIcons.notifications,
          activeIcon: AppIcons.notificationsActive,
          badgeCount: unreadCount,
        ),
        '/notifications'
      ),
      (
        const AppNavItem(
            label: 'Plus',
            icon: AppIcons.more,
            activeIcon: AppIcons.moreActive),
        '/parametres'
      ),
    ];

    final path = GoRouterState.of(context).uri.path;
    final index = tabs.indexWhere((t) => path.startsWith(t.$2));
    return Scaffold(
      body: _FonduOnglet(index: index, child: child),
      bottomNavigationBar: AppNavBar(
        items: [for (final t in tabs) t.$1],
        currentIndex: index < 0 ? 0 : index,
        onTap: (i) => context.go(tabs[i].$2),
      ),
    );
  }
}

/// Changement d'onglet : le contenu réapparaît en fondu (le navigateur de l'onglet est conservé).
class _FonduOnglet extends StatefulWidget {
  const _FonduOnglet({required this.index, required this.child});
  final int index;
  final Widget child;

  @override
  State<_FonduOnglet> createState() => _FonduOngletState();
}

class _FonduOngletState extends State<_FonduOnglet> with SingleTickerProviderStateMixin {
  late final _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 260), value: 1);
  late final _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);

  @override
  void didUpdateWidget(covariant _FonduOnglet old) {
    super.didUpdateWidget(old);
    if (old.index != widget.index && !(MediaQuery.maybeOf(context)?.disableAnimations ?? false)) {
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: _anim,
        child: SlideTransition(
          position: Tween(begin: const Offset(0, .015), end: Offset.zero).animate(_anim),
          child: widget.child,
        ),
      );
}
