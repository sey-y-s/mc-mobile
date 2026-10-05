import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';

void main() {
  group('NotificationType', () {
    test('fromApi returns corresponding enum for valid values', () {
      expect(NotificationType.fromApi('MISE_EN_RELATION'),
          NotificationType.miseEnRelation);
      expect(
          NotificationType.fromApi('VALIDATION'), NotificationType.validation);
      expect(NotificationType.fromApi('OPPORTUNITE'),
          NotificationType.opportunite);
      expect(NotificationType.fromApi('RAPPEL'), NotificationType.rappel);
      expect(NotificationType.fromApi('SYSTEME'), NotificationType.systeme);
    });

    test('fromApi returns autre for unknown or null values', () {
      expect(NotificationType.fromApi('VALEUR_INCONNUE_XYZ'),
          NotificationType.autre);
      expect(NotificationType.fromApi(null), NotificationType.autre);
      expect(NotificationType.fromApi(''), NotificationType.autre);
    });
  });

  group('NotificationDestinataire', () {
    test('fromJson and toJson work properly', () {
      final json = {
        'lu': true,
        'dateReception': '2026-05-10T12:00:00.000Z',
        'dateLecture': '2026-05-10T14:30:00.000Z',
      };
      final dest = NotificationDestinataire.fromJson(json);

      expect(dest.lu, isTrue);
      expect(dest.dateReception, DateTime.parse('2026-05-10T12:00:00.000Z'));
      expect(dest.dateLecture, DateTime.parse('2026-05-10T14:30:00.000Z'));

      final out = dest.toJson();
      expect(out['lu'], isTrue);
      expect(out['dateLecture'], isNotNull);
    });
  });

  group('AppNotification', () {
    test('fromJson with nested destinataire', () {
      final json = {
        'id': 'notif-100',
        'titre': 'Test Notif',
        'message': 'Ceci est un test',
        'type': 'MISE_EN_RELATION',
        'dateCreation': '2026-05-10T10:00:00.000Z',
        'referenceId': 'rel-123',
        'destinataire': {
          'lu': false,
          'dateReception': '2026-05-10T10:00:00.000Z',
        },
      };

      final notif = AppNotification.fromJson(json);

      expect(notif.id, 'notif-100');
      expect(notif.titre, 'Test Notif');
      expect(notif.type, NotificationType.miseEnRelation);
      expect(notif.lu, isFalse);
      expect(notif.referenceId, 'rel-123');
    });

    test('fromJson with flat structure (lu at root)', () {
      final json = {
        'id': 'notif-101',
        'titre': 'Titre plat',
        'message': 'Message plat',
        'type': 'VALIDATION',
        'lu': true,
        'dateCreation': '2026-05-10T11:00:00.000Z',
      };

      final notif = AppNotification.fromJson(json);

      expect(notif.id, 'notif-101');
      expect(notif.lu, isTrue);
      expect(notif.type, NotificationType.validation);
    });

    test('markAsRead updates status correctly', () {
      final notif = AppNotification(
        id: 'n-1',
        titre: 'Titre',
        message: 'Msg',
        type: NotificationType.rappel,
        dateCreation: DateTime(2026, 5, 10),
        destinataire: null,
      );

      final read = notif.markAsRead();
      expect(read.lu, isTrue);
      expect(read.destinataire?.dateLecture, isNotNull);
    });
  });
}
