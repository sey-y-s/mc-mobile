import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mlc_mobile/app/router/app_shell.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_repository.dart';
import 'package:mlc_mobile/features/notifications/presentation/notification_detail_screen.dart';
import 'package:mlc_mobile/features/notifications/presentation/notification_providers.dart';
import 'package:mlc_mobile/features/notifications/presentation/notifications_screen.dart';

/// Dépôt qui se comporte comme le serveur : marquer lue change l'état renvoyé ensuite.
class _Serveur implements NotificationRepository {
  final List<AppNotification> items = [
    AppNotification(
      id: 'n-1',
      notificationId: 'x-1',
      title: 'Validation reçue',
      message: 'Votre compétence a été examinée.',
      type: NotificationType.validation,
      receivedAt: DateTime(2026, 10, 30),
      createdAt: DateTime(2026, 10, 30),
      isRead: false,
    ),
  ];

  @override
  Future<List<AppNotification>> list({int page = 0, int size = 20}) async =>
      List.of(items);

  @override
  Future<AppNotification> get(String id) async =>
      items.firstWhere((e) => e.id == id);

  @override
  Future<int> unreadCount() async => items.where((e) => !e.isRead).length;

  @override
  Future<AppNotification> markRead(String id) async {
    final i = items.indexWhere((e) => e.id == id);
    items[i] = items[i].copyWith(isRead: true, readAt: DateTime.now());
    return items[i];
  }

  @override
  Future<void> markAllRead() async {
    for (var i = 0; i < items.length; i++) {
      items[i] = items[i].copyWith(isRead: true);
    }
  }
}

void main() {
  testWidgets(
    'après lecture, la pastille et la liste ne montrent plus « non lu »',
    (tester) async {
      final serveur = _Serveur();
      final router = GoRouter(
        initialLocation: '/notifications',
        routes: [
          ShellRoute(
            builder: (c, s, child) => AppShell(child: child),
            routes: [
              GoRoute(
                path: '/notifications',
                builder: (c, s) => const NotificationsScreen(),
              ),
              GoRoute(path: '/home', builder: (c, s) => const SizedBox()),
            ],
          ),
          GoRoute(
            path: '/notifications/:id',
            builder: (c, s) =>
                NotificationDetailScreen(id: s.pathParameters['id']),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            notificationRepositoryProvider.overrideWithValue(serveur),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      // Avant : une pastille « 1 » sur l'onglet Alertes, et la notification est non lue.
      expect(find.text('1'), findsOneWidget);
      expect(find.text('Validation reçue'), findsOneWidget);

      await tester.tap(find.text('Validation reçue'));
      await tester.pumpAndSettle();
      expect(find.text('Notification'), findsOneWidget); // écran de détail

      router.pop();
      await tester.pumpAndSettle();

      expect(serveur.items.single.isRead, isTrue);
      expect(
        find.text('1'),
        findsNothing,
        reason: 'la pastille doit disparaître',
      );
    },
  );
}
