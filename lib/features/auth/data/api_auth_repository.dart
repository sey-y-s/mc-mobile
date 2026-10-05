import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/storage/token_storage.dart';
import 'package:mlc_mobile/features/auth/domain/auth_repository.dart';

/// Contrat provisoire (à confirmer avec le backend) :
///  POST /api/auth/login    {identifiant, motDePasse} -> {accessToken, refreshToken?}
///  POST /api/auth/register {nom, prenom, telephone, email?, motDePasse, communeId?} -> idem login
///  401 sur login => identifiants invalides.
class ApiAuthRepository implements AuthRepository {
  ApiAuthRepository(this._dio, this._storage);
  final Dio _dio;
  final TokenStorage _storage;

  @override
  Future<void> login({required String identifiant, required String password}) async {
    try {
      final res = await guardDio(() => _dio.post<Map<String, dynamic>>(
            ApiEndpoints.login,
            data: {'identifiant': identifiant, 'motDePasse': password},
          ));
      await _saveTokens(res.data);
    } on UnauthorizedFailure {
      throw const InvalidCredentialsFailure();
    }
  }

  @override
  Future<void> register(RegisterData d) async {
    final res = await guardDio(() => _dio.post<Map<String, dynamic>>(ApiEndpoints.register, data: {
          'nom': d.nom,
          'prenom': d.prenom,
          'telephone': d.telephone,
          if (d.email != null) 'email': d.email,
          'motDePasse': d.password,
          if (d.communeId != null) 'communeId': d.communeId,
        }));
    await _saveTokens(res.data);
  }

  @override
  Future<void> logout() async {
    // Meilleur effort : le jeton local est supprimé même si le serveur est injoignable.
    try {
      await _dio.post<void>(ApiEndpoints.logout);
    } on DioException {
      // ignoré volontairement
    } finally {
      await _storage.clear();
    }
  }

  @override
  Future<void> requestPasswordReset(String identifiant) =>
      guardDio(() => _dio.post<void>(ApiEndpoints.forgotPassword, data: {'identifiant': identifiant}));

  @override
  Future<void> resetPassword({required String code, required String newPassword}) =>
      guardDio(() => _dio.post<void>(ApiEndpoints.resetPassword, data: {'code': code, 'motDePasse': newPassword}));

  Future<void> _saveTokens(Map<String, dynamic>? data) async {
    final access = data?['accessToken'];
    if (access is! String) throw const UnknownFailure();
    await _storage.save(access: access, refresh: data?['refreshToken'] as String?);
  }
}
