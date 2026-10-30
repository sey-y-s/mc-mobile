import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/features/notifications/presentation/notification_providers.dart';

import '../../support/fake_notification_repository.dart';

void main() {
  test('lire une notification fait baisser le compteur, même sans écran qui observe le contrôleur', () async {
    final repo = FakeNotificationRepository(unread: 3);
    final container = ProviderContainer(
      overrides: [notificationRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(container.dispose);

    final sub = container.listen(unreadNotificationCountProvider, (_, _) {});
    expect(await container.read(unreadNotificationCountProvider.future), 3);

    // Comme l'écran de détail : un simple read, sans listener sur le contrôleur.
    final ok = await container
        .read(notificationsControllerProvider.notifier)
        .markAsRead('n-1');
    expect(ok, isTrue);

    expect(await container.read(unreadNotificationCountProvider.future), 2);
    sub.close();
  });
}
