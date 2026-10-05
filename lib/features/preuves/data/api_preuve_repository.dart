import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/media/picked_media.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/network/page_utils.dart';
import 'package:mlc_mobile/core/network/upload.dart';
import 'package:mlc_mobile/features/preuves/domain/preuve_models.dart';
import 'package:mlc_mobile/features/preuves/domain/preuve_repository.dart';

/// Contrat provisoire :
///  GET  /api/citoyens/me/preuves?page&size
///  GET  /api/citoyen-competences/{id}/preuves
///  GET  /api/preuves/{id}
///  POST /api/citoyen-competences/{id}/preuves  multipart: fichier + type
class ApiPreuveRepository implements PreuveRepository {
  ApiPreuveRepository(this._dio);
  final Dio _dio;

  List<Preuve> _list(dynamic body) => pageItems(body)
      .map((e) => Preuve.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  Future<List<Preuve>> listMine({int page = 0, int size = 20}) async {
    final res = await guardDio(() => _dio.get<dynamic>(
        ApiEndpoints.citoyenPreuves(ApiEndpoints.me),
        queryParameters: {'page': page, 'size': size}));
    return _list(res.data);
  }

  @override
  Future<List<Preuve>> listForCompetence(String citoyenCompetenceId) async {
    final res = await guardDio(
        () => _dio.get<dynamic>(ApiEndpoints.preuves(citoyenCompetenceId)));
    return _list(res.data);
  }

  @override
  Future<Preuve> get(String id) async {
    final res = await guardDio(
        () => _dio.get<Map<String, dynamic>>(ApiEndpoints.preuve(id)));
    return Preuve.fromJson(res.data!);
  }

  @override
  Future<Preuve> add({
    required String citoyenCompetenceId,
    required PreuveType type,
    required PickedMedia fichier,
    void Function(double progress)? onProgress,
  }) async {
    final res = await guardDio(() => uploadMultipart<Map<String, dynamic>>(
          _dio,
          ApiEndpoints.preuves(citoyenCompetenceId),
          file: fichier,
          fields: {'type': type.apiCode},
          onProgress: onProgress,
        ));
    return Preuve.fromJson(res.data!);
  }
}
