import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_repository.dart';

/// État en mémoire avec données fictives réalistes (Mali).
class MockNotificationRepository implements NotificationRepository {
  const MockNotificationRepository();

  static final List<AppNotification> _items = _initial();

  static List<AppNotification> _initial() => [
        AppNotification(
          id: 'notif-1',
          titre: 'Demande de mise en relation',
          message:
              'Atelier Métallurgie du Baoulé (Bamako, Commune VI) souhaite échanger avec vous suite à votre profil en Soudure.',
          type: NotificationType.miseEnRelation,
          dateCreation: DateTime.now().subtract(const Duration(minutes: 25)),
          destinataire: NotificationDestinataire(
            lu: false,
            dateReception:
                DateTime.now().subtract(const Duration(minutes: 25)),
          ),
          referenceId: 'rel-1',
        ),
        AppNotification(
          id: 'notif-2',
          titre: 'Compétence validée',
          message:
              'Félicitations ! Votre compétence « Soudure à l\'arc » a été validée avec succès par le Centre de Formation Professionnelle de Bamako.',
          type: NotificationType.validation,
          dateCreation: DateTime.now().subtract(const Duration(hours: 3)),
          destinataire: NotificationDestinataire(
            lu: false,
            dateReception: DateTime.now().subtract(const Duration(hours: 3)),
          ),
          referenceId: 'val-1',
        ),
        AppNotification(
          id: 'notif-3',
          titre: 'Nouvelle opportunité disponible',
          message:
              'Programme d\'insertion et perfectionnement pour jeunes artisans à Sikasso. Les candidatures sont ouvertes.',
          type: NotificationType.opportunite,
          dateCreation: DateTime.now().subtract(const Duration(days: 1)),
          destinataire: NotificationDestinataire(
            lu: true,
            dateReception: DateTime.now().subtract(const Duration(days: 1)),
            dateLecture:
                DateTime.now().subtract(const Duration(hours: 18)),
          ),
          referenceId: 'opp-1',
        ),
        AppNotification(
          id: 'notif-4',
          titre: 'Passeport de compétences incomplet',
          message:
              'Ajoutez une attestation ou un document pour valoriser votre compétence en Couture professionnelle.',
          type: NotificationType.rappel,
          dateCreation: DateTime.now().subtract(const Duration(days: 2)),
          destinataire: NotificationDestinataire(
            lu: true,
            dateReception: DateTime.now().subtract(const Duration(days: 2)),
            dateLecture:
                DateTime.now().subtract(const Duration(days: 1, hours: 4)),
          ),
          referenceId: 'cc-2',
        ),
        AppNotification(
          id: 'notif-5',
          titre: 'Session de tests numériques',
          message:
              'Évaluez vos compétences numériques de base et obtenez un badge officiel vérifié pour votre passeport.',
          type: NotificationType.systeme,
          dateCreation: DateTime.now().subtract(const Duration(days: 4)),
          destinataire: NotificationDestinataire(
            lu: true,
            dateReception: DateTime.now().subtract(const Duration(days: 4)),
            dateLecture: DateTime.now().subtract(const Duration(days: 3)),
          ),
          referenceId: 'test-1',
        ),
      ];

  /// Pour les tests : remet la liste initiale.
  static void resetForTests() => _items
    ..clear()
    ..addAll(_initial());

  Future<void> _latency([int ms = 300]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  @override
  Future<List<AppNotification>> list({int page = 0, int size = 20}) async {
    await _latency(350);
    final sorted = [..._items]
      ..sort((a, b) => b.dateCreation.compareTo(a.dateCreation));
    return sorted.skip(page * size).take(size).toList();
  }

  @override
  Future<int> unreadCount() async {
    await _latency(150);
    return _items.where((n) => !n.lu).length;
  }

  @override
  Future<AppNotification> get(String id) async {
    await _latency(250);
    if (id == 'error-network') throw const NetworkFailure();
    if (id == 'error-server') throw const ServerFailure();

    final notif = _items.firstWhere(
      (n) => n.id == id,
      orElse: () => throw const NotFoundFailure(),
    );
    return notif;
  }

  @override
  Future<void> markRead(String id) async {
    await _latency(200);
    final index = _items.indexWhere((n) => n.id == id);
    if (index >= 0) {
      final notif = _items[index];
      if (!notif.lu) {
        _items[index] = notif.markAsRead();
      }
    }
  }

  @override
  Future<void> markAllRead() async {
    await _latency(300);
    final now = DateTime.now();
    for (var i = 0; i < _items.length; i++) {
      if (!_items[i].lu) {
        _items[i] = _items[i].markAsRead(readAt: now);
      }
    }
  }
}
