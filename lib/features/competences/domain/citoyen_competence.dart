import 'package:mlc_mobile/features/preuves/domain/preuve_models.dart';

enum Niveau {
  debutant('Débutant'),
  intermediaire('Intermédiaire'),
  expert('Expert');

  const Niveau(this.label);
  final String label;
  static Niveau fromApi(String v) =>
      Niveau.values.firstWhere((e) => e.name.toUpperCase() == v.toUpperCase(), orElse: () => Niveau.debutant);
}

enum EtatCompetence {
  declaree('Déclarée'),
  attestee('Preuve reçue'),
  validee('Validée');

  const EtatCompetence(this.label);
  final String label;
  static EtatCompetence fromApi(String v) =>
      EtatCompetence.values.firstWhere((e) => e.name.toUpperCase() == v.toUpperCase(), orElse: () => EtatCompetence.declaree);
}

/// Secteur dans lequel le citoyen a acquis la compétence : il fixe les preuves acceptées.
enum Parcours {
  formel(
    'FORMEL',
    'Secteur formel',
    "J'ai appris à l'école ou dans une formation (diplôme, certificat, attestation, stage).",
  ),
  informel(
    'INFORMEL',
    'Secteur informel',
    "J'ai appris sur le terrain, sans passer par l'école.",
  );

  const Parcours(this.apiCode, this.label, this.description);
  final String apiCode;
  final String label;
  final String description;

  /// Preuves que le citoyen peut joindre pour ce parcours.
  List<PreuveType> get preuves => switch (this) {
        Parcours.formel => const [
            PreuveType.diplome,
            PreuveType.certificat,
            PreuveType.attestation,
            PreuveType.attestationStage,
          ],
        Parcours.informel => const [PreuveType.certificatCentre],
      };

  /// Liste renvoyée par le serveur (ex. ["FORMEL"]). Absente ou vide : les deux secteurs.
  static List<Parcours> listFromApi(Object? v) {
    if (v is! List) return Parcours.values;
    final l = [for (final e in v) ?fromApi(e?.toString())];
    return l.isEmpty ? Parcours.values : List.unmodifiable(Parcours.values.where(l.contains));
  }

  /// Phrase qui explique pourquoi un seul secteur est possible.
  static String? noteUnique(List<Parcours> possibles) => possibles.length != 1
      ? null
      : possibles.first == Parcours.formel
          ? "Cette compétence s'acquiert par une formation : seul le secteur formel est possible."
          : "Cette compétence s'acquiert sur le terrain : seul le secteur informel est possible.";

  static Parcours? fromApi(String? v) {
    for (final p in Parcours.values) {
      if (p.apiCode == v) return p;
    }
    return null;
  }
}

/// Classe d'association Citoyen <-> Competence (niveau, état, dateDeclaration).
/// Contrat JSON provisoire (DTO plat) : voir fromJson.
class CitoyenCompetence {
  const CitoyenCompetence({
    required this.id,
    required this.competenceId,
    required this.competenceNom,
    required this.niveau,
    required this.etat,
    required this.dateDeclaration,
    this.secteurNom,
    this.parcours,
    this.nombrePreuves = 0,
    this.parcoursPossibles = Parcours.values,
  });

  final String id;
  final String competenceId;
  final String competenceNom;
  final String? secteurNom;
  final Niveau niveau;
  final EtatCompetence etat;
  final DateTime dateDeclaration;

  /// Null pour une compétence déclarée avant l'arrivée des parcours : à préciser par le citoyen.
  final Parcours? parcours;
  final int nombrePreuves;

  /// Secteurs possibles pour cette compétence (fixés par le référentiel).
  final List<Parcours> parcoursPossibles;

  /// Types de preuve que le citoyen peut joindre à cette compétence.
  List<PreuveType> get preuvesAcceptees =>
      (parcours ?? (parcoursPossibles.length == 1 ? parcoursPossibles.first : null))?.preuves ?? PreuveType.addable;

  CitoyenCompetence copyWith({EtatCompetence? etat, Parcours? parcours, int? nombrePreuves}) => CitoyenCompetence(
        id: id,
        competenceId: competenceId,
        competenceNom: competenceNom,
        secteurNom: secteurNom,
        niveau: niveau,
        etat: etat ?? this.etat,
        dateDeclaration: dateDeclaration,
        parcours: parcours ?? this.parcours,
        nombrePreuves: nombrePreuves ?? this.nombrePreuves,
        parcoursPossibles: parcoursPossibles,
      );

  factory CitoyenCompetence.fromJson(Map<String, dynamic> j) => CitoyenCompetence(
        id: j['id'] as String,
        competenceId: j['competenceId'] as String,
        competenceNom: j['competenceNom'] as String,
        secteurNom: j['secteurNom'] as String?,
        niveau: Niveau.fromApi(j['niveau'] as String),
        etat: EtatCompetence.fromApi(j['etat'] as String),
        dateDeclaration: DateTime.parse(j['dateDeclaration'] as String),
        parcours: Parcours.fromApi(j['parcours'] as String?),
        nombrePreuves: (j['nombrePreuves'] as num?)?.toInt() ?? 0,
        parcoursPossibles: Parcours.listFromApi(j['parcoursPossibles']),
      );
}
