/// Contrat de la fonctionnalité « mise_en_relation » (endpoint : /api/demandes-mise-en-relation).
///
/// TODO: déclarer ici les méthodes suivantes avec les modèles de domain/mise_en_relation_models.dart,
/// puis les implémenter dans Mock*Repository ET Api*Repository (mêmes signatures) :
///  - listReceived({page,size})
///  - listSent({page,size})
///  - get(id)
///  - send(talentId, message?)
///  - respond(id, accept: bool)
/// Règles : listes paginées (page/size) ; les erreurs sont des AppFailure (jamais d'exception Dio brute).
abstract interface class MiseEnRelationRepository {}
