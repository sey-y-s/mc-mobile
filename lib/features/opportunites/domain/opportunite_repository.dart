/// Contrat de la fonctionnalité « opportunites » (endpoint : /api/opportunites).
///
/// TODO: déclarer ici les méthodes suivantes avec les modèles de domain/opportunite_models.dart,
/// puis les implémenter dans Mock*Repository ET Api*Repository (mêmes signatures) :
///  - list({type, categorieId, page, size})
///  - get(id)
/// Règles : listes paginées (page/size) ; les erreurs sont des AppFailure (jamais d'exception Dio brute).
abstract interface class OpportuniteRepository {}
