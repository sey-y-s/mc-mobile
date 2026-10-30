import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/security/jwt_utils.dart';
import 'package:mlc_mobile/core/security/session.dart';
import 'package:mlc_mobile/core/storage/token_storage.dart';

final dioProvider = Provider<Dio>((ref) {
  return buildDio(
    storage: ref.watch(tokenStorageProvider),
    onUnauthorized: () => ref.read(sessionProvider.notifier).expire(),
  );
});

Dio buildDio({
  required TokenStorage storage,
  required Future<void> Function() onUnauthorized,
}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {'Accept': 'application/json'},
    ),
  );
  // Volontairement aucun LogInterceptor : pas de token ni de données perso dans les logs.
  dio.interceptors.add(AuthInterceptor(storage, onUnauthorized, dio));
  return dio;
}

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage, this._onUnauthorized, this._dio);

  /// Option de requête : une réponse 401 ne ferme pas la session (ex. chargement d'une photo).
  static const sansDeconnexion = 'sansDeconnexion';
  final TokenStorage _storage;
  final Future<void> Function() _onUnauthorized;
  final Dio _dio;

  /// Marque une requête déjà rejouée après un renouvellement : jamais plus d'une fois.
  static const dejaRenouvelee = 'dejaRenouvelee';

  /// Verrou : plusieurs requêtes qui échouent en même temps partagent un seul renouvellement
  /// (le jeton de renouvellement est à usage unique, un second appel serait refusé).
  Future<_Renouvellement>? _renouvellementEnCours;

  Future<_Renouvellement> _renouveler() =>
      _renouvellementEnCours ??= _renouvelerSansVerrou().whenComplete(() => _renouvellementEnCours = null);

  Future<_Renouvellement> _renouvelerSansVerrou() async {
    final refresh = await _storage.readRefresh();
    if (refresh == null || refresh.isEmpty) return _Renouvellement.refuse;
    try {
      // Client à part : il ne doit passer ni par cet intercepteur ni par ses jetons.
      final client = Dio(BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Accept': 'application/json'},
      ));
      final res = await client.post<Map<String, dynamic>>(ApiEndpoints.refresh, data: {'refreshToken': refresh});
      final access = res.data?['token'];
      if (access is! String || access.isEmpty) return _Renouvellement.refuse;
      await _storage.save(access: access, refresh: res.data?['refreshToken'] as String?);
      return _Renouvellement.reussi;
    } on DioException catch (e) {
      final code = e.response?.statusCode;
      // Refus du serveur (jeton expiré, déjà utilisé, révoqué) : la session est terminée.
      // Panne réseau : on ne déconnecte pas, l'utilisateur réessaiera.
      return (code == 400 || code == 401 || code == 403) ? _Renouvellement.refuse : _Renouvellement.indisponible;
    }
  }

  bool _isAuthCall(RequestOptions o) => o.path.startsWith(ApiEndpoints.auth);

  // Ces données doivent être disponibles avant la création d'un compte.
  // Ne pas envoyer un ancien jeton stocké par le navigateur sur ces appels publics.
  bool _isPublicTerritoryRead(RequestOptions o) {
    if (o.method.toUpperCase() != 'GET') return false;
    final path = o.path;
    return path == ApiEndpoints.regions ||
        path == ApiEndpoints.communes ||
        path.startsWith('${ApiEndpoints.communes}/region/');
  }

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (!_isAuthCall(options) && !_isPublicTerritoryRead(options)) {
      var token = await _storage.readAccess();
      // Accès déjà expiré : on le renouvelle avant d'envoyer, au lieu d'attendre un 401.
      if (token != null && token.isNotEmpty && JwtUtils.isExpired(token)) {
        if (await _renouveler() == _Renouvellement.reussi) token = await _storage.readAccess();
      }
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode == 401 &&
        err.requestOptions.extra[sansDeconnexion] != true &&
        !_isAuthCall(err.requestOptions) &&
        !_isPublicTerritoryRead(err.requestOptions)) {
      final opts = err.requestOptions;
      if (opts.extra[dejaRenouvelee] != true) {
        switch (await _renouveler()) {
          case _Renouvellement.reussi:
            // Une requête avec fichier ne peut pas être rejouée (son flux est consommé) :
            // la session est renouvelée, l'utilisateur renvoie simplement son fichier.
            if (opts.data is FormData) {
              handler.next(err);
              return;
            }
            try {
              final token = await _storage.readAccess();
              opts.extra[dejaRenouvelee] = true;
              if (token != null) opts.headers['Authorization'] = 'Bearer $token';
              handler.resolve(await _dio.fetch<dynamic>(opts));
            } on DioException catch (e) {
              handler.next(e);
            }
            return;
          case _Renouvellement.indisponible:
            handler.next(err);
            return;
          case _Renouvellement.refuse:
            break;
        }
      }
      await _onUnauthorized();
    }
    handler.next(err);
  }
}

/// Résultat d'une tentative de renouvellement de session.
enum _Renouvellement { reussi, refuse, indisponible }

/// Exécute un appel Dio et convertit toute erreur en [AppFailure].
Future<T> guardDio<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on DioException catch (e) {
    throw AppFailure.fromDio(e);
  }
}
