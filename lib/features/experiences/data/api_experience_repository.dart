import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/network/page_utils.dart';
import 'package:mlc_mobile/features/experiences/domain/experience_models.dart';
import 'package:mlc_mobile/features/experiences/domain/experience_repository.dart';

/// Contrat provisoire :
///  GET    /api/citoyens/me/experiences?page&size
///  GET    /api/citoyens/me/experiences/{id}
///  POST   /api/citoyens/me/experiences        (corps = ExperienceInput.toJson)
///  PUT    /api/citoyens/me/experiences/{id}
///  DELETE /api/citoyens/me/experiences/{id}   (204)
class ApiExperienceRepository implements ExperienceRepository {
  ApiExperienceRepository(this._dio);
  final Dio _dio;

  String get _base => ApiEndpoints.citoyenExperiences(ApiEndpoints.me);

  @override
  Future<List<Experience>> list({int page = 0, int size = 20}) async {
    final res = await guardDio(() => _dio.get<dynamic>(_base, queryParameters: {'page': page, 'size': size}));
    return pageItems(res.data).map((e) => Experience.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<Experience> get(String id) async {
    final res = await guardDio(() => _dio.get<Map<String, dynamic>>('$_base/$id'));
    return Experience.fromJson(res.data!);
  }

  @override
  Future<Experience> create(ExperienceInput input) async {
    final res = await guardDio(() => _dio.post<Map<String, dynamic>>(_base, data: input.toJson()));
    return Experience.fromJson(res.data!);
  }

  @override
  Future<Experience> update(String id, ExperienceInput input) async {
    final res = await guardDio(() => _dio.put<Map<String, dynamic>>('$_base/$id', data: input.toJson()));
    return Experience.fromJson(res.data!);
  }

  @override
  Future<void> delete(String id) => guardDio(() => _dio.delete<void>('$_base/$id'));
}