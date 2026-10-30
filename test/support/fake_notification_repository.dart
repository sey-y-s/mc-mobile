import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_repository.dart';

/// Dépôt de test : seul le nombre de notifications non lues compte.
class FakeNotificationRepository implements NotificationRepository {
  FakeNotificationRepository({required this.unread});
  int unread;

  @override
  Future<int> unreadCount() async => unread;

  @override
  Future<AppNotification> markRead(String id) async {
    unread--;
    return AppNotification(
      id: id,
      notificationId: id,
      title: 't',
      message: 'm',
      type: NotificationType.systeme,
      receivedAt: DateTime(2026),
      createdAt: DateTime(2026),
      isRead: true,
    );
  }

  @override
  Future<void> markAllRead() async => unread = 0;

  @override
  Future<List<AppNotification>> list({int page = 0, int size = 20}) async =>
      const [];

  @override
  Future<AppNotification> get(String id) => throw UnimplementedError();
}
