import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/security/session.dart';
import 'package:mlc_mobile/features/notifications/data/api_notification_repository.dart';
import 'package:mlc_mobile/features/notifications/data/mock_notification_repository.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return AppConfig.useMocks
      ? const MockNotificationRepository()
      : ApiNotificationRepository(
          ref.watch(dioProvider),
          ref.watch(tokenStorageProvider),
        );
});

/// Compteur d'invalidation pour notifier les listeners d'un changement de statut de lecture
final notificationsRevisionProvider = StateProvider<int>((ref) => 0);

/// Nombre de notifications non lues (pour la pastille sur l'onglet Alertes)
final unreadNotificationCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  ref.watch(notificationsRevisionProvider);
  return ref.watch(notificationRepositoryProvider).unreadCount();
});

/// Détail d'une notification spécifique
final notificationDetailProvider = FutureProvider.autoDispose
    .family<AppNotification, String>((ref, id) {
      ref.watch(notificationsRevisionProvider);
      return ref.watch(notificationRepositoryProvider).get(id);
    });

/// Contrôleur d'actions pour les notifications (marquer lu, tout marquer lu)
class NotificationsController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Marque une notification comme lue et rafraîchit l'état
  Future<bool> markAsRead(String id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationRepositoryProvider).markRead(id);
    });
    // Dans tous les cas, listes et pastille se resynchronisent avec le serveur : même si la réponse
    // n'a pas pu être lue, la notification a pu être marquée lue côté serveur.
    ref.read(notificationsRevisionProvider.notifier).state++;
    return !state.hasError;
  }

  /// Marque toutes les notifications comme lues
  Future<bool> markAllAsRead() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(notificationRepositoryProvider).markAllRead();
    });
    if (state.hasError) return false;
    ref.read(notificationsRevisionProvider.notifier).state++;
    return true;
  }
}

/// Volontairement sans autoDispose : l'écran de détail lance « marquer lue » sans l'observer ;
/// un contrôleur libéré en cours d'appel n'incrémentait jamais la révision, et la pastille restait fausse.
final notificationsControllerProvider =
    AsyncNotifierProvider<NotificationsController, void>(
      NotificationsController.new,
    );
