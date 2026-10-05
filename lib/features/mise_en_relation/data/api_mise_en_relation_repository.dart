import 'package:dio/dio.dart';
import 'package:mlc_mobile/features/mise_en_relation/domain/mise_en_relation_repository.dart';

// TODO: implémenter MiseEnRelationRepository avec Dio. Utiliser UNIQUEMENT ApiEndpoints (core/network/api_endpoints.dart)
// — endpoint principal : /api/demandes-mise-en-relation —, entourer chaque appel de guardDio(...) (core/network/dio_provider.dart),
// utiliser ApiEndpoints.me pour le citoyen connecté, et accepter une Page Spring ({content: [...]}) ou une liste.
// Modèle : lib/features/competences/data/api_competences_repository.dart. Le backend n'est pas terminé :
// signaler tout écart de contrat dans docs/CONTRAT_API_PROVISOIRE.md.
class ApiMiseEnRelationRepository implements MiseEnRelationRepository {
  const ApiMiseEnRelationRepository(this._dio);
  final Dio _dio;
}
