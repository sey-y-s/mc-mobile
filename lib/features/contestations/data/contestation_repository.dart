import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';

/// Ce que le citoyen conteste ou demande de corriger.
enum ObjetContestation {
  decision('DECISION_VALIDATION', 'Une décision de validation'),
  profil('DONNEE_PROFIL', 'Une information de mon profil'),
  autre('AUTRE', 'Autre chose');

  const ObjetContestation(this.apiCode, this.label);
  final String apiCode;
  final String label;

  static ObjetContestation fromApi(String? v) =>
      ObjetContestation.values.firstWhere((e) => e.apiCode == v, orElse: () => ObjetContestation.autre);
}

/// Informations du profil dont on peut demander la correction (clé envoyée au serveur, libellé affiché).
const champsProfil = <(String, String)>[
  ('nom', 'Mon nom'),
  ('prenom', 'Mon prénom'),
  ('sexe', 'Mon sexe'),
  ('commune', 'Ma commune'),
  ('telephone', 'Mon téléphone'),
  ('email', 'Mon e-mail'),
  ('competence', 'Une compétence'),
  ('experience', 'Une expérience'),
  ('autre', 'Autre information'),
];

String libelleChamp(String? cle) =>
    champsProfil.where((c) => c.$1 == cle).map((c) => c.$2).firstOrNull ?? (cle ?? '');

enum StatutContestation {
  ouverte('OUVERTE', 'Envoyée'),
  enExamen('EN_EXAMEN', 'En cours d’examen'),
  acceptee('ACCEPTEE', 'Acceptée'),
  rejetee('REJETEE', 'Non retenue');

  const StatutContestation(this.apiCode, this.label);
  final String apiCode;
  final String label;

  bool get enCours => this == ouverte || this == enExamen;

  static StatutContestation fromApi(String? v) =>
      StatutContestation.values.firstWhere((e) => e.apiCode == v, orElse: () => StatutContestation.ouverte);
}

class Contestation {
  const Contestation({
    required this.id,
    required this.objet,
    required this.motif,
    required this.statut,
    required this.dateCreation,
    this.validationId,
    this.competenceNom,
    this.champConcerne,
    this.reponse,
    this.nouvelleDecision,
  });

  final String id;
  final ObjetContestation objet;
  final String motif;
  final StatutContestation statut;
  final DateTime dateCreation;
  final String? validationId;
  final String? competenceNom;
  final String? champConcerne;
  final String? reponse;
  final String? nouvelleDecision;

  String get titre => switch (objet) {
        ObjetContestation.decision => 'Décision : ${competenceNom ?? 'compétence'}',
        ObjetContestation.profil => 'Correction : ${libelleChamp(champConcerne)}',
        ObjetContestation.autre => champConcerne == null || champConcerne!.isEmpty ? 'Autre demande' : champConcerne!,
      };

  factory Contestation.fromJson(Map<String, dynamic> j) => Contestation(
        id: j['id'] as String,
        objet: ObjetContestation.fromApi(j['typeObjet'] as String?),
        motif: j['motif']?.toString() ?? '',
        statut: StatutContestation.fromApi(j['statut'] as String?),
        dateCreation: DateTime.tryParse(j['dateCreation']?.toString() ?? '') ?? DateTime.now(),
        validationId: j['validationId'] as String?,
        competenceNom: j['competenceNom'] as String?,
        champConcerne: j['champConcerne'] as String?,
        reponse: j['reponse'] as String?,
        nouvelleDecision: j['nouvelleDecision'] as String?,
      );
}

abstract class ContestationRepository {
  Future<List<Contestation>> mesContestations();
  Future<Contestation> creer({required ObjetContestation objet, required String motif, String? validationId, String? champConcerne});
}

class ApiContestationRepository implements ContestationRepository {
  const ApiContestationRepository(this._dio);
  final Dio _dio;

  @override
  Future<List<Contestation>> mesContestations() => guardDio(() async {
        final r = await _dio.get<List<dynamic>>(ApiEndpoints.citoyenMesContestations);
        return (r.data ?? const []).whereType<Map<String, dynamic>>().map(Contestation.fromJson).toList();
      });

  @override
  Future<Contestation> creer({required ObjetContestation objet, required String motif, String? validationId, String? champConcerne}) =>
      guardDio(() async {
        final r = await _dio.post<Map<String, dynamic>>(ApiEndpoints.citoyenMesContestations, data: {
          'typeObjet': objet.apiCode,
          'motif': motif,
          'validationId': ?validationId,
          'champConcerne': ?champConcerne,
        });
        return Contestation.fromJson(r.data ?? const {});
      });
}

class MockContestationRepository implements ContestationRepository {
  MockContestationRepository();
  static final List<Contestation> _items = [];

  static void resetForTests() => _items.clear();

  @override
  Future<List<Contestation>> mesContestations() async => List.unmodifiable(_items);

  @override
  Future<Contestation> creer({required ObjetContestation objet, required String motif, String? validationId, String? champConcerne}) async {
    if (motif.trim().isEmpty) throw ArgumentError('Expliquez votre demande.');
    if (objet == ObjetContestation.decision &&
        _items.any((c) => c.validationId == validationId && c.statut.enCours)) {
      throw StateError('Une contestation de cette décision est déjà en cours d’examen.');
    }
    final c = Contestation(
      id: 'contest-${_items.length + 1}',
      objet: objet,
      motif: motif.trim(),
      statut: StatutContestation.ouverte,
      dateCreation: DateTime.now(),
      validationId: validationId,
      champConcerne: champConcerne,
    );
    _items.insert(0, c);
    return c;
  }
}
