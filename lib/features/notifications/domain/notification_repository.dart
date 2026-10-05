/// Contrat de la fonctionnalité « notifications » (endpoint : /api/notifications).
///
/// TODO: déclarer ici les méthodes suivantes avec les modèles de domain/notification_models.dart,
/// puis les implémenter dans Mock*Repository ET Api*Repository (mêmes signatures) :
///  - list({page,size})
///  - unreadCount()
///  - markRead(id)
///  - markAllRead()
/// Règles : listes paginées (page/size) ; les erreurs sont des AppFailure (jamais d'exception Dio brute).
abstract interface class NotificationRepository {}
