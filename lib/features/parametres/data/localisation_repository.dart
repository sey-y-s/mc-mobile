import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';

/// Origine de la commune de référence.
enum SourceLocalisation {
  declaration('Choisie par vous'),
  gpsConfirmee('Confirmée après une détection'),
  administration("Corrigée par l'administration");

  const SourceLocalisation(this.label);
  final String label;

  static SourceLocalisation? fromApi(String? v) => switch (v) {
        'DECLARATION' => SourceLocalisation.declaration,
        'GPS_CONFIRMEE' => SourceLocalisation.gpsConfirmee,
        'ADMINISTRATION' => SourceLocalisation.administration,
        _ => null,
      };
}

/// Proposition de changement de commune : jamais appliquée sans votre confirmation.
class SuggestionCommune {
  const SuggestionCommune({required this.id, required this.communeId, required this.communeNom, this.regionNom});
  final String id;
  final String communeId;
  final String communeNom;
  final String? regionNom;

  String get libelle => regionNom == null ? communeNom : '$communeNom ($regionNom)';

  factory SuggestionCommune.fromJson(Map<String, dynamic> j) => SuggestionCommune(
        id: j['id'] as String,
        communeId: j['communeId'] as String,
        communeNom: j['communeNom'] as String,
        regionNom: j['regionNom'] as String?,
      );
}

/// Commune de référence du citoyen. Aucune coordonnée GPS n'est jamais conservée ni renvoyée.
class MaLocalisation {
  const MaLocalisation({
    this.communeId,
    this.communeNom,
    this.regionNom,
    this.source,
    this.confirmeeLe,
    this.gpsConsenti = false,
    this.suggestion,
  });

  final String? communeId;
  final String? communeNom;
  final String? regionNom;
  final SourceLocalisation? source;
  final DateTime? confirmeeLe;
  final bool gpsConsenti;
  final SuggestionCommune? suggestion;

  bool get communeConnue => communeId != null;
  String get libelle => communeNom == null ? 'Commune non renseignée' : regionNom == null ? communeNom! : '$communeNom, $regionNom';

  factory MaLocalisation.fromJson(Map<String, dynamic> j) => MaLocalisation(
        communeId: j['communeId'] as String?,
        communeNom: j['communeNom'] as String?,
        regionNom: j['regionNom'] as String?,
        source: SourceLocalisation.fromApi(j['source'] as String?),
        confirmeeLe: DateTime.tryParse(j['confirmeeLe']?.toString() ?? ''),
        gpsConsenti: j['gpsConsenti'] == true,
        suggestion: j['demandeEnAttente'] is Map<String, dynamic>
            ? SuggestionCommune.fromJson(j['demandeEnAttente'] as Map<String, dynamic>)
            : null,
      );
}

enum ResultatDetection { identique, suggestionCreee, suggestionEnAttente, delaiEnCours, communeInconnue, consentementRequis }

class Detection {
  const Detection({required this.resultat, required this.message, this.suggestion});
  final ResultatDetection resultat;
  final String message;
  final SuggestionCommune? suggestion;

  factory Detection.fromJson(Map<String, dynamic> j) => Detection(
        resultat: switch (j['resultat']) {
          'IDENTIQUE' => ResultatDetection.identique,
          'SUGGESTION_CREEE' => ResultatDetection.suggestionCreee,
          'SUGGESTION_EN_ATTENTE' => ResultatDetection.suggestionEnAttente,
          'DELAI_EN_COURS' => ResultatDetection.delaiEnCours,
          'CONSENTEMENT_REQUIS' => ResultatDetection.consentementRequis,
          _ => ResultatDetection.communeInconnue,
        },
        message: j['message']?.toString() ?? '',
        suggestion: j['suggestion'] is Map<String, dynamic>
            ? SuggestionCommune.fromJson(j['suggestion'] as Map<String, dynamic>)
            : null,
      );
}

abstract class LocalisationRepository {
  Future<MaLocalisation> lire();
  Future<MaLocalisation> declarer(String communeId);
  Future<MaLocalisation> consentement(bool consenti);

  /// La position n'est envoyée que pour cette requête : le serveur en déduit la commune puis l'oublie.
  Future<Detection> detecter(double latitude, double longitude);
  Future<MaLocalisation> accepter(String suggestionId);
  Future<MaLocalisation> refuser(String suggestionId);
}

class ApiLocalisationRepository implements LocalisationRepository {
  const ApiLocalisationRepository(this._dio);
  final Dio _dio;

  static const _base = ApiEndpoints.citoyenMaLocalisation;

  Future<MaLocalisation> _loc(Future<Response<Map<String, dynamic>>> Function() call) =>
      guardDio(() async => MaLocalisation.fromJson((await call()).data ?? const {}));

  @override
  Future<MaLocalisation> lire() => _loc(() => _dio.get<Map<String, dynamic>>(_base));

  @override
  Future<MaLocalisation> declarer(String communeId) =>
      _loc(() => _dio.put<Map<String, dynamic>>(_base, data: {'communeId': communeId}));

  @override
  Future<MaLocalisation> consentement(bool consenti) =>
      _loc(() => _dio.put<Map<String, dynamic>>('$_base/consentement', data: {'consenti': consenti}));

  @override
  Future<Detection> detecter(double latitude, double longitude) => guardDio(() async {
        final r = await _dio.post<Map<String, dynamic>>('$_base/detection',
            data: {'latitude': latitude, 'longitude': longitude});
        return Detection.fromJson(r.data ?? const {});
      });

  @override
  Future<MaLocalisation> accepter(String suggestionId) =>
      _loc(() => _dio.post<Map<String, dynamic>>('$_base/suggestions/$suggestionId/accepter'));

  @override
  Future<MaLocalisation> refuser(String suggestionId) =>
      _loc(() => _dio.post<Map<String, dynamic>>('$_base/suggestions/$suggestionId/refuser'));
}

/// Mode démonstration : mêmes règles que le serveur (consentement, pas de changement automatique).
class MockLocalisationRepository implements LocalisationRepository {
  MaLocalisation _etat = MaLocalisation(
    communeId: 'commune-1',
    communeNom: 'Commune I',
    regionNom: 'Bamako',
    source: SourceLocalisation.declaration,
    confirmeeLe: DateTime(2026, 3, 1),
  );

  @override
  Future<MaLocalisation> lire() async => _etat;

  @override
  Future<MaLocalisation> declarer(String communeId) async => _etat = MaLocalisation(
        communeId: communeId,
        communeNom: 'Nouvelle commune',
        source: SourceLocalisation.declaration,
        confirmeeLe: DateTime.now(),
        gpsConsenti: _etat.gpsConsenti,
      );

  @override
  Future<MaLocalisation> consentement(bool consenti) async => _etat = MaLocalisation(
        communeId: _etat.communeId,
        communeNom: _etat.communeNom,
        regionNom: _etat.regionNom,
        source: _etat.source,
        confirmeeLe: _etat.confirmeeLe,
        gpsConsenti: consenti,
        suggestion: consenti ? _etat.suggestion : null,
      );

  @override
  Future<Detection> detecter(double latitude, double longitude) async {
    if (!_etat.gpsConsenti) {
      return const Detection(resultat: ResultatDetection.consentementRequis, message: 'Activez la détection de votre commune.');
    }
    if (_etat.suggestion != null) {
      return Detection(resultat: ResultatDetection.suggestionEnAttente, message: 'Une proposition attend votre réponse.', suggestion: _etat.suggestion);
    }
    const s = SuggestionCommune(id: 'sugg-1', communeId: 'commune-3', communeNom: 'Commune III', regionNom: 'Bamako');
    _etat = MaLocalisation(
      communeId: _etat.communeId,
      communeNom: _etat.communeNom,
      regionNom: _etat.regionNom,
      source: _etat.source,
      confirmeeLe: _etat.confirmeeLe,
      gpsConsenti: true,
      suggestion: s,
    );
    return const Detection(resultat: ResultatDetection.suggestionCreee, message: 'Vous semblez être à Commune III.', suggestion: s);
  }

  @override
  Future<MaLocalisation> accepter(String suggestionId) async {
    final s = _etat.suggestion;
    if (s == null) return _etat;
    return _etat = MaLocalisation(
      communeId: s.communeId,
      communeNom: s.communeNom,
      regionNom: s.regionNom,
      source: SourceLocalisation.gpsConfirmee,
      confirmeeLe: DateTime.now(),
      gpsConsenti: _etat.gpsConsenti,
    );
  }

  @override
  Future<MaLocalisation> refuser(String suggestionId) async => _etat = MaLocalisation(
        communeId: _etat.communeId,
        communeNom: _etat.communeNom,
        regionNom: _etat.regionNom,
        source: _etat.source,
        confirmeeLe: _etat.confirmeeLe,
        gpsConsenti: _etat.gpsConsenti,
      );
}
