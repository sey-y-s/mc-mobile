import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';

enum TalentAvailability {
  disponible('DISPONIBLE', 'Disponible'),
  bientotDisponible('BIENTOT_DISPONIBLE', 'Bientôt disponible'),
  indisponible('INDISPONIBLE', 'Indisponible');

  const TalentAvailability(this.apiCode, this.label);
  final String apiCode;
  final String label;

  static TalentAvailability fromApi(String? value) => TalentAvailability.values
      .firstWhere((e) => e.apiCode == value?.toUpperCase(),
          orElse: () => TalentAvailability.disponible);
}

class TalentCompetence {
  const TalentCompetence({
    required this.name,
    required this.level,
    this.validated = false,
    this.hasEvidence = false,
  });
  final String name;
  final Niveau level;
  final bool validated;
  final bool hasEvidence;

  factory TalentCompetence.fromJson(Map<String, dynamic> json) =>
      TalentCompetence(
        name: (json['competenceNom'] ?? json['nom'] ?? 'Compétence').toString(),
        level: Niveau.fromApi((json['niveau'] ?? 'DEBUTANT').toString()),
        validated: json['validee'] == true || json['validee'] == 'VALIDEE',
        hasEvidence: json['aPreuve'] == true,
      );
}

/// Résumé public anonymisé : le parseur ne conserve aucun nom, contact ou photo.
class TalentSummary {
  const TalentSummary({
    required this.id,
    required this.skills,
    required this.regionName,
    required this.communeName,
    required this.availability,
    required this.validationCount,
    required this.evidenceCount,
    required this.hasPortfolio,
  });
  final String id;
  final List<TalentCompetence> skills;
  final String regionName;
  final String communeName;
  final TalentAvailability availability;
  final int validationCount;
  final int evidenceCount;
  final bool hasPortfolio;

  factory TalentSummary.fromJson(Map<String, dynamic> json) {
    final rawSkills = json['competences'];
    return TalentSummary(
      id: (json['id'] ?? json['identifiantAnonyme'] ?? '').toString(),
      skills: rawSkills is List
          ? rawSkills.whereType<Map>().map((e) =>
              TalentCompetence.fromJson(Map<String, dynamic>.from(e))).toList()
          : const [],
      regionName: (json['regionNom'] ?? json['region'] ?? 'Région non précisée').toString(),
      communeName: (json['communeNom'] ?? json['commune'] ?? 'Commune non précisée').toString(),
      availability: TalentAvailability.fromApi(
          (json['disponibilite'] ?? json['availability'])?.toString()),
      validationCount: _int(json['nbValidations']),
      evidenceCount: _int(json['nbPreuves']),
      hasPortfolio: json['aPortfolio'] == true,
    );
  }
}

class TalentProfileAnonymized {
  const TalentProfileAnonymized({
    required this.summary,
    this.portfolioTitles = const [],
  });
  final TalentSummary summary;
  final List<String> portfolioTitles;

  factory TalentProfileAnonymized.fromJson(Map<String, dynamic> json) =>
      TalentProfileAnonymized(
        summary: TalentSummary.fromJson(json['resume'] is Map
            ? Map<String, dynamic>.from(json['resume'] as Map)
            : json),
        portfolioTitles: (json['portfolio'] is List
                ? json['portfolio'] as List
                : const [])
            .whereType<Map>()
            .map((e) => (e['titre'] ?? '').toString())
            .where((e) => e.isNotEmpty)
            .toList(),
      );
}

class TalentFilters {
  const TalentFilters({
    this.query = '',
    this.competenceId,
    this.metierId,
    this.regionId,
    this.communeId,
    this.availability,
    this.minimumLevel,
  });
  final String query;
  final String? competenceId;
  final String? metierId;
  final String? regionId;
  final String? communeId;
  final TalentAvailability? availability;
  final Niveau? minimumLevel;

  TalentFilters copyWith({
    String? query,
    String? competenceId,
    String? metierId,
    String? regionId,
    String? communeId,
    TalentAvailability? availability,
    Niveau? minimumLevel,
    bool clearCompetence = false,
    bool clearMetier = false,
    bool clearRegion = false,
    bool clearCommune = false,
    bool clearAvailability = false,
    bool clearMinimumLevel = false,
  }) =>
      TalentFilters(
        query: query ?? this.query,
        competenceId: clearCompetence ? null : (competenceId ?? this.competenceId),
        metierId: clearMetier ? null : (metierId ?? this.metierId),
        regionId: clearRegion ? null : (regionId ?? this.regionId),
        communeId: clearCommune ? null : (communeId ?? this.communeId),
        availability: clearAvailability ? null : (availability ?? this.availability),
        minimumLevel: clearMinimumLevel ? null : (minimumLevel ?? this.minimumLevel),
      );

  @override
  bool operator ==(Object other) =>
      other is TalentFilters &&
      query == other.query &&
      competenceId == other.competenceId &&
      metierId == other.metierId &&
      regionId == other.regionId &&
      communeId == other.communeId &&
      availability == other.availability &&
      minimumLevel == other.minimumLevel;

  @override
  int get hashCode => Object.hash(
      query, competenceId, metierId, regionId, communeId, availability, minimumLevel);
}

int _int(Object? value) => value is num ? value.toInt() : int.tryParse('$value') ?? 0;
