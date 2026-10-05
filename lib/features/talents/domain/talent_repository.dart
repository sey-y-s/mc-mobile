/// Contrat de la fonctionnalité « talents » (endpoint : /api/citoyens/recherche (provisoire)).
///
/// TODO: déclarer ici les méthodes suivantes avec les modèles de domain/talent_models.dart,
/// puis les implémenter dans Mock*Repository ET Api*Repository (mêmes signatures) :
///  - search(TalentFilters, {page,size})
///  - getAnonymized(id)
/// Règles : listes paginées (page/size) ; les erreurs sont des AppFailure (jamais d'exception Dio brute).
abstract interface class TalentRepository {}
