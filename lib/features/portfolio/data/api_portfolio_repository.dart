import 'package:dio/dio.dart';
import 'package:mlc_mobile/features/portfolio/domain/portfolio_repository.dart';

// TODO: implémenter PortfolioRepository avec Dio. Utiliser UNIQUEMENT ApiEndpoints (core/network/api_endpoints.dart)
// — endpoint principal : /api/citoyens/{id}/portfolio —, entourer chaque appel de guardDio(...) (core/network/dio_provider.dart),
// utiliser ApiEndpoints.me pour le citoyen connecté, et accepter une Page Spring ({content: [...]}) ou une liste.
// Modèle : lib/features/competences/data/api_competences_repository.dart. Le backend n'est pas terminé :
// signaler tout écart de contrat dans docs/CONTRAT_API_PROVISOIRE.md.
class ApiPortfolioRepository implements PortfolioRepository {
  const ApiPortfolioRepository(this._dio);
  final Dio _dio;
}
