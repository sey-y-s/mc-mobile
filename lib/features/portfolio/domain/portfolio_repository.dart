/// Contrat de la fonctionnalité « portfolio » (endpoint : /api/citoyens/{id}/portfolio).
///
/// TODO: déclarer ici les méthodes suivantes avec les modèles de domain/portfolio_models.dart,
/// puis les implémenter dans Mock*Repository ET Api*Repository (mêmes signatures) :
///  - list({page,size})
///  - get(id)
///  - create(input)
///  - update(id,input)
///  - delete(id)
///  - addMedia(id, fichier)
///  - removeMedia(mediaId)
/// Règles : listes paginées (page/size) ; les erreurs sont des AppFailure (jamais d'exception Dio brute).
abstract interface class PortfolioRepository {}
