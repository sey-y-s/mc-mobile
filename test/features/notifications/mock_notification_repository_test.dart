import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/features/notifications/data/mock_notification_repository.dart';

void main() {
  late MockNotificationRepository repository;

  setUp(() {
    MockNotificationRepository.resetForTests();
    repository = const MockNotificationRepository();
  });

  group('MockNotificationRepository', () {
    test('list returns paginated results sorted by dateCreation descending',
        () async {
      final items = await repository.list(page: 0, size: 3);
      expect(items.length, 3);
      expect(items[0].dateCreation.isAfter(items[1].dateCreation) ||
              items[0].dateCreation.isAtSameMomentAs(items[1].dateCreation),
          isTrue);
    });

    test('unreadCount returns number of unread notifications', () async {
      final count = await repository.unreadCount();
      expect(count, greaterThan(0));
    });

    test('markRead marks a single notification as read', () async {
      final initialUnread = await repository.unreadCount();
      await repository.markRead('notif-1');

      final notif = await repository.get('notif-1');
      expect(notif.lu, isTrue);

      final newUnread = await repository.unreadCount();
      expect(newUnread, initialUnread - 1);
    });

    test('markAllRead marks all notifications as read', () async {
      await repository.markAllRead();
      final count = await repository.unreadCount();
      expect(count, 0);
    });

    test('get throws NotFoundFailure for non-existent id', () async {
      expect(
        () => repository.get('notif-inconnue-xyz'),
        throwsA(isA<NotFoundFailure>()),
      );
    });

    test('get throws NetworkFailure for special error id', () async {
      expect(
        () => repository.get('error-network'),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
