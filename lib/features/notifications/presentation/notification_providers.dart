import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/notifications/data/api_notification_repository.dart';
import 'package:mlc_mobile/features/notifications/data/mock_notification_repository.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return AppConfig.useMocks
      ? const MockNotificationRepository()
      : ApiNotificationRepository(ref.watch(dioProvider));
});

// TODO: ajouter ici les providers d'état de la fonctionnalité (FutureProvider.autoDispose pour les lectures,
// AutoDisposeAsyncNotifier pour les formulaires/actions) et les consommer dans les écrans de
// lib/features/notifications/presentation/ avec AsyncValueView. Modèle : competences_providers.dart.
