/// Contrat de la fonctionnalité « tests » (endpoint : /api/tests (provisoire)).
///
/// TODO: déclarer ici les méthodes suivantes avec les modèles de domain/test_numerique_models.dart,
/// puis les implémenter dans Mock*Repository ET Api*Repository (mêmes signatures) :
///  - list()
///  - get(id) avec questions
///  - submit(testId, answers) -> ResultatTest
///  - listResults()
/// Règles : listes paginées (page/size) ; les erreurs sont des AppFailure (jamais d'exception Dio brute).
abstract interface class TestNumeriqueRepository {}
