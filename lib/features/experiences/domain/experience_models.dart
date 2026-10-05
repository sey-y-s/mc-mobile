import 'package:mlc_mobile/core/utils/date_format.dart';

/// Compétence mobilisée par une expérience : toujours une compétence DÉJÀ déclarée par le citoyen.
class ExperienceCompetence {
  const ExperienceCompetence({required this.citoyenCompetenceId, required this.nom});
  final String citoyenCompetenceId;
  final String nom;

  factory ExperienceCompetence.fromJson(Map<String, dynamic> j) =>
      ExperienceCompetence(citoyenCompetenceId: j['citoyenCompetenceId'] as String, nom: j['competenceNom'] as String);
}

/// Contrat JSON provisoire (DTO plat) : voir fromJson.
class Experience {
  const Experience({
    required this.id,
    required this.titre,
    required this.dateDebut,
    this.entreprise,
    this.description,
    this.dateFin,
    this.enCours = false,
    this.reconversion = false,
    this.competences = const [],
  });

  final String id;
  final String titre;
  final String? entreprise;
  final String? description;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final bool enCours;

  /// Marque un changement de métier.
  final bool reconversion;
  final List<ExperienceCompetence> competences;

  factory Experience.fromJson(Map<String, dynamic> j) => Experience(
        id: j['id'] as String,
        titre: j['titre'] as String,
        entreprise: j['entreprise'] as String?,
        description: j['description'] as String?,
        dateDebut: DateTime.parse(j['dateDebut'] as String),
        dateFin: j['dateFin'] == null ? null : DateTime.parse(j['dateFin'] as String),
        enCours: j['enCours'] as bool? ?? false,
        reconversion: j['reconversion'] as bool? ?? false,
        competences: ((j['competences'] as List<dynamic>?) ?? const [])
            .map((e) => ExperienceCompetence.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

/// Données envoyées pour créer ou modifier une expérience.
class ExperienceInput {
  const ExperienceInput({
    required this.titre,
    required this.dateDebut,
    this.entreprise,
    this.description,
    this.dateFin,
    this.enCours = false,
    this.reconversion = false,
    this.citoyenCompetenceIds = const [],
  });

  final String titre;
  final String? entreprise;
  final String? description;
  final DateTime dateDebut;
  final DateTime? dateFin;
  final bool enCours;
  final bool reconversion;
  final List<String> citoyenCompetenceIds;

  factory ExperienceInput.fromExperience(Experience e) => ExperienceInput(
        titre: e.titre,
        entreprise: e.entreprise,
        description: e.description,
        dateDebut: e.dateDebut,
        dateFin: e.dateFin,
        enCours: e.enCours,
        reconversion: e.reconversion,
        citoyenCompetenceIds: [for (final c in e.competences) c.citoyenCompetenceId],
      );

  Map<String, dynamic> toJson() => {
        'titre': titre,
        'entreprise': entreprise,
        'description': description,
        'dateDebut': isoDate(dateDebut),
        'dateFin': enCours || dateFin == null ? null : isoDate(dateFin!),
        'enCours': enCours,
        'reconversion': reconversion,
        'citoyenCompetenceIds': citoyenCompetenceIds,
      };
}