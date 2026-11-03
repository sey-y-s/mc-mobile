import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_models.dart';
import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_repository.dart';

///  GET  /api/v1/parcours-validation/competences/{id}
///  POST /api/v1/evaluateur/demandes {citoyenCompetenceId, type, centreId | preuveId}
class ApiParcoursValidationRepository implements ParcoursValidationRepository {
  const ApiParcoursValidationRepository(this._dio);
  final Dio _dio;

  @override
  Future<ParcoursValidation> get(String citoyenCompetenceId) async {
    final res = await guardDio(
      () => _dio.get<Map<String, dynamic>>(
        ApiEndpoints.parcoursValidation(citoyenCompetenceId),
      ),
    );
    final data = res.data;
    if (data == null) throw NotFoundFailure();
    return ParcoursValidation.fromJson(data);
  }

  @override
  Future<void> demanderEvaluation({
    required String citoyenCompetenceId,
    required ModaliteValidation modalite,
    String? centreId,
    String? preuveId,
  }) async {
    final type = modalite.typeDemande;
    if (type == null) throw ValidationFailure();
    // Validation documentaire : une preuve, pas de centre. Les autres modalités : un centre, pas de document.
    if (modalite == ModaliteValidation.documentaire
        ? preuveId == null
        : centreId == null) {
      throw ValidationFailure();
    }
    await guardDio(
      () => _dio.post<dynamic>(
        '/api/v1/evaluateur/demandes',
        data: {
          'citoyenCompetenceId': citoyenCompetenceId,
          'type': type,
          'centreId': ?centreId,
          'preuveId': ?preuveId,
        },
      ),
    );
  }
}
