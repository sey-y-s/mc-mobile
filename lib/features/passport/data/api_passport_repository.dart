import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/media/picked_media.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/network/page_utils.dart';
import 'package:mlc_mobile/core/network/upload.dart';
import 'package:mlc_mobile/features/passport/domain/passport_models.dart';
import 'package:mlc_mobile/features/passport/domain/passport_repository.dart';

/// Contrat provisoire (voir docs/CONTRAT_API_PROVISOIRE.md, section Passeport). Toutes les écritures renvoient le Citoyen à jour.
class ApiPassportRepository implements PassportRepository {
  ApiPassportRepository(this._dio);
  final Dio _dio;

  String get _me => ApiEndpoints.citoyen(ApiEndpoints.me);

  Citoyen _citoyen(Response<Map<String, dynamic>> res) =>
      Citoyen.fromJson(res.data!);

  @override
  Future<Citoyen> getMine() async =>
      _citoyen(await guardDio(() => _dio.get<Map<String, dynamic>>(_me)));

  @override
  Future<Citoyen> updateProfile(
          {required String nom, required String prenom, Sexe? sexe}) async =>
      _citoyen(await guardDio(() => _dio.put<Map<String, dynamic>>(_me,
          data: {'nom': nom, 'prenom': prenom, 'sexe': sexe?.apiCode})));

  @override
  Future<Citoyen> updateCommune(String communeId) async =>
      _citoyen(await guardDio(() => _dio.put<Map<String, dynamic>>(
          ApiEndpoints.citoyenCommune(ApiEndpoints.me),
          data: {'communeId': communeId})));

  @override
  Future<Citoyen> updateAvailability(Disponibilite value) async =>
      _citoyen(await guardDio(() => _dio.put<Map<String, dynamic>>(
          ApiEndpoints.citoyenDisponibilite(ApiEndpoints.me),
          data: {'disponibilite': value.apiCode})));

  @override
  Future<Citoyen> updatePhoto(PickedMedia media,
          {void Function(double progress)? onProgress}) async =>
      _citoyen(await guardDio(() => uploadMultipart<Map<String, dynamic>>(
            _dio,
            ApiEndpoints.citoyenPhoto(ApiEndpoints.me),
            file: media,
            onProgress: onProgress,
          )));

  @override
  Future<List<Region>> listRegions() async {
    final res = await guardDio(() => _dio.get<dynamic>(ApiEndpoints.regions));
    return pageItems(res.data)
        .map((e) => Region.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<List<Commune>> listCommunes(String regionId) async {
    final res = await guardDio(() => _dio.get<dynamic>(ApiEndpoints.communes,
        queryParameters: {'regionId': regionId}));
    return pageItems(res.data)
        .map((e) => Commune.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
