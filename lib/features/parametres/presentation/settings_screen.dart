import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/router/routes.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/widgets/app_card.dart';
import 'package:mlc_mobile/core/widgets/app_dialogs.dart';
import 'package:mlc_mobile/core/widgets/app_icons.dart';
import 'package:mlc_mobile/features/auth/presentation/auth_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Paramètres')),
    body: ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Column(
            children: [
              _SettingsItem(
                icon: AppIcons.person,
                title: 'Compte',
                subtitle: 'Téléphone et email',
                onTap: () => context.push('/parametres/compte'),
              ),
              const Divider(),
              _SettingsItem(
                icon: AppIcons.lock,
                title: 'Sécurité',
                subtitle: 'Changer le mot de passe',
                onTap: () => context.push('/parametres/securite'),
              ),
              const Divider(),
              _SettingsItem(
                icon: AppIcons.tune,
                title: 'Préférences',
                subtitle: 'Données et notifications',
                onTap: () => context.push('/parametres/preferences'),
              ),
              const Divider(),
              _SettingsItem(
                icon: AppIcons.document,
                title: 'Conditions d’utilisation',
                subtitle: 'Consulter les conditions',
                onTap: () => context.push('/parametres/conditions'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        AppCard(
          child: ListTile(
            leading: const Icon(AppIcons.logout, color: Colors.red),
            title: const Text('Se déconnecter'),
            onTap: () async {
              final yes = await confirmDialog(
                context,
                title: 'Se déconnecter ?',
                message:
                    'Vous devrez vous reconnecter pour accéder à votre compte.',
                confirmLabel: 'Déconnexion',
                destructive: true,
              );
              if (!yes || !context.mounted) return;
              try {
                await ref.read(authControllerProvider.notifier).logout();
                if (context.mounted) context.go(AppRoutes.login);
              } catch (e) {
                if (context.mounted)
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(failureMessage(e))));
              }
            },
          ),
        ),
      ],
    ),
  );
}

class _SettingsItem extends StatelessWidget {
  const _SettingsItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon),
    title: Text(title),
    subtitle: Text(subtitle),
    trailing: const Icon(AppIcons.chevron),
    onTap: onTap,
  );
}
