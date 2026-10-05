/// Contrat de la fonctionnalité « experiences » (endpoint : /api/citoyens/{id}/experiences).
///
/// TODO: déclarer ici les méthodes suivantes avec les modèles de domain/experience_models.dart,
/// puis les implémenter dans Mock*Repository ET Api*Repository (mêmes signatures) :
///  - list({page,size})
///  - get(id)
///  - create(ExperienceInput)
///  - update(id, ExperienceInput)
///  - delete(id)
/// Règles : listes paginées (page/size) ; les erreurs sont des AppFailure (jamais d'exception Dio brute).
abstract interface class ExperienceRepository {}
