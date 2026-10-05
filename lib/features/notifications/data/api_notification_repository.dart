import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/network/page_utils.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_models.dart';
import 'package:mlc_mobile/features/notifications/domain/notification_repository.dart';

class ApiNotificationRepository implements NotificationRepository {
  const ApiNotificationRepository(this._dio);
  final Dio _dio;

  List<AppNotification> _list(dynamic body) => pageItems(body)
      .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  Future<List<AppNotification>> list({int page = 0, int size = 20}) async {
    final res = await guardDio(() => _dio.get<dynamic>(
          ApiEndpoints.notifications,
          queryParameters: {'page': page, 'size': size},
        ));
    return _list(res.data);
  }

  @override
  Future<int> unreadCount() async {
    final res = await guardDio(
        () => _dio.get<dynamic>(ApiEndpoints.notificationsUnreadCount));
    if (res.data is num) return (res.data as num).toInt();
    if (res.data is Map) {
      final map = res.data as Map;
      final val = map['count'] ?? map['unreadCount'] ?? map['total'];
      if (val is num) return val.toInt();
    }
    return 0;
  }

  @override
  Future<AppNotification> get(String id) async {
    final res = await guardDio(() =>
        _dio.get<Map<String, dynamic>>(ApiEndpoints.notification(id)));
    return AppNotification.fromJson(res.data!);
  }

  @override
  Future<void> markRead(String id) async {
    await guardDio(() => _dio.post<dynamic>(ApiEndpoints.notificationRead(id)));
  }

  @override
  Future<void> markAllRead() async {
    await guardDio(
        () => _dio.post<dynamic>(ApiEndpoints.notificationsReadAll));
  }
}
