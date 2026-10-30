enum OpportuniteType {
  formationGratuite('FORMATION_GRATUITE', 'Formation'),
  bourse('BOURSE', 'Bourse'),
  programme('PROGRAMME', 'Programme'),
  appelCandidature('APPEL_CANDIDATURE', 'Appel à candidatures'),
  concours('CONCOURS', 'Concours'),
  insertion('INSERTION', 'Insertion'),
  accompagnement('ACCOMPAGNEMENT', 'Accompagnement'),
  autre('AUTRE', 'Autre');

  const OpportuniteType(this.apiCode, this.label);
  final String apiCode;
  final String label;

  static OpportuniteType fromApi(String? value) => OpportuniteType.values
      .firstWhere((e) => e.apiCode == value?.toUpperCase(),
          orElse: () => OpportuniteType.autre);
}

enum OpportuniteStatus {
  publiee('PUBLIEE', 'Publiée'),
  brouillon('BROUILLON', 'Brouillon'),
  expiree('EXPIREE', 'Expirée'),
  archivee('ARCHIVEE', 'Archivée'),
  annulee('ANNULEE', 'Annulée');

  const OpportuniteStatus(this.apiCode, this.label);
  final String apiCode;
  final String label;

  static OpportuniteStatus fromApi(String? value) => OpportuniteStatus.values
      .firstWhere((e) => e.apiCode == value?.toUpperCase(),
          orElse: () => OpportuniteStatus.brouillon);
}

/// Proximité de l'opportunité avec la localité du citoyen connecté.
enum Proximite {
  commune('COMMUNE', 'Dans votre commune'),
  region('REGION', 'Dans votre région'),
  nationale('NATIONALE', 'Tout le Mali'),
  autre('AUTRE', 'Autre localité');

  const Proximite(this.apiCode, this.label);
  final String apiCode;
  final String label;

  bool get estLocale => this == Proximite.commune || this == Proximite.region;

  static Proximite? fromApi(String? value) {
    for (final p in Proximite.values) {
      if (p.apiCode == value?.toUpperCase()) return p;
    }
    return null;
  }
}

class Opportunite {
  const Opportunite({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.status,
    required this.publishedAt,
    this.categoryId,
    this.categoryName,
    this.expirationDate,
    this.externalUrl,
    this.localite,
    this.regionNom,
    this.communeNom,
    this.proximite,
    this.dejaPostule = false,
    this.statutCandidature,
  });
  final String id;
  final String title;
  final String description;
  final OpportuniteType type;
  final OpportuniteStatus status;
  final DateTime publishedAt;
  final String? categoryId;
  final String? categoryName;
  final DateTime? expirationDate;
  final String? externalUrl;

  /// « Bamako · Commune IV », « Région de Ségou » ou « Tout le Mali ».
  final String? localite;
  final String? regionNom;
  final String? communeNom;

  /// Connue seulement pour un citoyen connecté (liste « pour moi »).
  final Proximite? proximite;
  final bool dejaPostule;

  /// ENVOYEE, RETENUE ou NON_RETENUE.
  final String? statutCandidature;

  Opportunite copyWith({bool? dejaPostule, String? statutCandidature}) => Opportunite(
        id: id,
        title: title,
        description: description,
        type: type,
        status: status,
        publishedAt: publishedAt,
        categoryId: categoryId,
        categoryName: categoryName,
        expirationDate: expirationDate,
        externalUrl: externalUrl,
        localite: localite,
        regionNom: regionNom,
        communeNom: communeNom,
        proximite: proximite,
        dejaPostule: dejaPostule ?? this.dejaPostule,
        statutCandidature: statutCandidature ?? this.statutCandidature,
      );

  /// Réponse « pour moi » : { opportunite: {...}, proximite, dejaPostule, statutCandidature }.
  factory Opportunite.fromPourMoi(Map<String, dynamic> json) {
    final base = Opportunite.fromJson(Map<String, dynamic>.from(json['opportunite'] as Map));
    return Opportunite(
      id: base.id,
      title: base.title,
      description: base.description,
      type: base.type,
      status: base.status,
      publishedAt: base.publishedAt,
      categoryId: base.categoryId,
      categoryName: base.categoryName,
      expirationDate: base.expirationDate,
      externalUrl: base.externalUrl,
      localite: base.localite,
      regionNom: base.regionNom,
      communeNom: base.communeNom,
      proximite: Proximite.fromApi(json['proximite']?.toString()),
      dejaPostule: json['dejaPostule'] == true,
      statutCandidature: json['statutCandidature']?.toString(),
    );
  }

  bool get isVisible {
    final today = DateTime.now();
    final expiry = expirationDate;
    return status == OpportuniteStatus.publiee &&
        (expiry == null || !DateTime(expiry.year, expiry.month, expiry.day)
            .isBefore(DateTime(today.year, today.month, today.day)));
  }

  factory Opportunite.fromJson(Map<String, dynamic> json) {
    DateTime? date(Object? value) =>
        value is String ? DateTime.tryParse(value) : null;
    final category = json['categorie'];
    return Opportunite(
      id: (json['id'] ?? '').toString(),
      title: (json['titre'] ?? json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      type: OpportuniteType.fromApi(json['type']?.toString()),
      status: OpportuniteStatus.fromApi((json['statut'] ?? json['status'])?.toString()),
      publishedAt: date(json['datePublication']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      categoryId: (json['categorieId'] ?? (category is Map ? category['id'] : null))?.toString(),
      categoryName: (json['categorieNom'] ?? (category is Map ? category['nom'] : null))?.toString(),
      expirationDate: date(json['dateExpiration']),
      externalUrl: (json['lienUrl'] ?? json['url'])?.toString(),
      localite: json['localite']?.toString(),
      regionNom: json['regionNom']?.toString(),
      communeNom: json['communeNom']?.toString(),
    );
  }
}

class OpportuniteFilters {
  const OpportuniteFilters({this.type, this.categoryId});
  final OpportuniteType? type;
  final String? categoryId;

  OpportuniteFilters copyWith({
    OpportuniteType? type,
    String? categoryId,
    bool clearType = false,
    bool clearCategory = false,
  }) => OpportuniteFilters(
        type: clearType ? null : (type ?? this.type),
        categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
      );
}
