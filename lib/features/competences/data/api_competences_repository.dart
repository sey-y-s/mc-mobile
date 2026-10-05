import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/network/page_utils.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';
import 'package:mlc_mobile/features/competences/domain/competence_ref.dart';
import 'package:mlc_mobile/features/competences/domain/competences_repository.dart';

/// Contrat provisoire :
///  GET  /api/citoyens/me/competences?page&size
///  GET  /api/citoyens/me/competences/{id}
///  POST /api/citoyens/me/competences {competenceId, niveau: DEBUTANT|INTERMEDIAIRE|EXPERT} (409 si déjà déclarée)
///  GET  /api/competences?q=&size=20 -> [{id, nom, secteurNom}]
class ApiCompetencesRepository implements CompetencesRepository {
  ApiCompetencesRepository(this._dio);
  final Dio _dio;

  String get _base => ApiEndpoints.citoyenCompetences(ApiEndpoints.me);

  @override
  Future<List<CitoyenCompetence>> list({int page = 0, int size = 20}) async {
    final res = await guardDio(() => _dio
        .get<dynamic>(_base, queryParameters: {'page': page, 'size': size}));
    return pageItems(res.data)
        .map((e) => CitoyenCompetence.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<CitoyenCompetence> get(String id) async {
    final res =
        await guardDio(() => _dio.get<Map<String, dynamic>>('$_base/$id'));
    return CitoyenCompetence.fromJson(res.data!);
  }

  @override
  Future<CitoyenCompetence> add(
      {required String competenceId, required Niveau niveau}) async {
    final res = await guardDio(() => _dio.post<Map<String, dynamic>>(
          _base,
          data: {
            'competenceId': competenceId,
            'niveau': niveau.name.toUpperCase()
          },
        ));
    return CitoyenCompetence.fromJson(res.data!);
  }

  @override
  Future<List<CompetenceRef>> searchReferentiel(String query) async {
    final res = await guardDio(() => _dio.get<dynamic>(ApiEndpoints.competences,
        queryParameters: {'q': query, 'size': 20}));
    return pageItems(res.data)
        .map((e) => CompetenceRef.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
