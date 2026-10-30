/// Les 5 modalités de validation d'une compétence (complémentaires, sans hiérarchie).
enum ModaliteValidation {
  documentaire('DOCUMENTAIRE'),
  testNumerique('TEST_NUMERIQUE'),
  pratiqueCentre('PRATIQUE_CENTRE'),
  portfolioMedia('PORTFOLIO_MEDIA'),
  maitreArtisan('MAITRE_ARTISAN');

  const ModaliteValidation(this.apiCode);
  final String apiCode;

  static ModaliteValidation? fromApi(String? v) {
    for (final m in ModaliteValidation.values) {
      if (m.apiCode == v) return m;
    }
    return null;
  }

  /// Type de demande envoyé au serveur quand l'évaluation se fait auprès d'un centre (null sinon).
  String? get typeDemande => switch (this) {
        ModaliteValidation.pratiqueCentre => 'VALIDATION_PRATIQUE',
        ModaliteValidation.portfolioMedia => 'PORTFOLIO_MEDIA',
        ModaliteValidation.maitreArtisan => 'MAITRE_ARTISAN',
        _ => null,
      };
}

/// Les 4 statuts d'avancement d'une compétence.
enum StatutParcours {
  declaree('DECLAREE', 'Déclarée'),
  preuveRecue('PREUVE_RECUE', 'Preuve reçue'),
  enCoursEvaluation('EN_COURS_EVALUATION', "En cours d'évaluation"),
  validee('VALIDEE', 'Validée');

  const StatutParcours(this.apiCode, this.label);
  final String apiCode;
  final String label;

  static StatutParcours fromApi(String? v) => StatutParcours.values.firstWhere(
        (s) => s.apiCode == v,
        orElse: () => StatutParcours.declaree,
      );
}

/// Centre pouvant évaluer la compétence, avec sa position par rapport au citoyen.
class CentreProche {
  const CentreProche({required this.id, required this.nom, this.adresse, this.proximite});
  final String id;
  final String nom;
  final String? adresse;
  final String? proximite;

  factory CentreProche.fromJson(Map<String, dynamic> json) => CentreProche(
        id: json['id'].toString(),
        nom: (json['nom'] ?? 'Centre').toString(),
        adresse: json['adresse']?.toString(),
        proximite: (json['proximiteLibelle'] ?? json['proximite'])?.toString(),
      );
}

class ModaliteProposee {
  const ModaliteProposee({
    required this.modalite,
    required this.libelle,
    required this.description,
    required this.disponible,
    required this.recommandee,
    this.raison,
    this.action,
    this.testId,
    this.seuilReussite,
    this.criteres,
    this.centres = const [],
  });

  final ModaliteValidation modalite;
  final String libelle;
  final String description;
  final bool disponible;
  final bool recommandee;
  final String? raison;

  /// DEPOSER_PREUVE, PASSER_TEST, DEMANDER_EVALUATION ou AJOUTER_REALISATIONS (null si indisponible).
  final String? action;
  final String? testId;
  final int? seuilReussite;
  final String? criteres;
  final List<CentreProche> centres;

  /// Null si le serveur envoie une modalité que cette version de l'application ne connaît pas.
  static ModaliteProposee? fromJson(Map<String, dynamic> json) {
    final modalite = ModaliteValidation.fromApi(json['modalite']?.toString());
    if (modalite == null) return null;
    final centres = json['centres'];
    return ModaliteProposee(
      modalite: modalite,
      libelle: (json['libelle'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      disponible: json['disponible'] == true,
      recommandee: json['recommandee'] == true,
      raison: json['raison']?.toString(),
      action: json['action']?.toString(),
      testId: json['testId']?.toString(),
      seuilReussite: (json['seuilReussite'] as num?)?.toInt(),
      criteres: json['criteres']?.toString(),
      centres: centres is List
          ? centres.whereType<Map>().map((c) => CentreProche.fromJson(Map<String, dynamic>.from(c))).toList()
          : const [],
    );
  }
}

/// Parcours de validation proposé pour une compétence du citoyen.
class ParcoursValidation {
  const ParcoursValidation({
    required this.citoyenCompetenceId,
    required this.competenceNom,
    required this.statut,
    required this.enAttenteEvaluation,
    required this.message,
    required this.modalites,
    this.recommandee,
  });

  final String citoyenCompetenceId;
  final String competenceNom;
  final StatutParcours statut;

  /// Aucune modalité n'est réalisable près du citoyen : le dossier attend, il n'est pas rejeté.
  final bool enAttenteEvaluation;
  final ModaliteValidation? recommandee;
  final String message;
  final List<ModaliteProposee> modalites;

  factory ParcoursValidation.fromJson(Map<String, dynamic> json) {
    final liste = json['modalites'];
    return ParcoursValidation(
      citoyenCompetenceId: json['citoyenCompetenceId'].toString(),
      competenceNom: (json['competenceNom'] ?? '').toString(),
      statut: StatutParcours.fromApi(json['statut']?.toString()),
      enAttenteEvaluation: json['enAttenteEvaluation'] == true,
      recommandee: ModaliteValidation.fromApi(json['recommandee']?.toString()),
      message: (json['message'] ?? '').toString(),
      modalites: liste is List
          ? liste
              .whereType<Map>()
              .map((m) => ModaliteProposee.fromJson(Map<String, dynamic>.from(m)))
              .whereType<ModaliteProposee>()
              .toList()
          : const [],
    );
  }
}
