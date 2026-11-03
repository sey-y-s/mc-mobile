/// Demande d'évaluation reçue par le centre d'un évaluateur (contrat : GET /api/v1/evaluateur/demandes et /historique).
class DemandeEvaluation {
  const DemandeEvaluation({
    required this.id,
    required this.citoyenNom,
    required this.competenceNom,
    required this.type,
    required this.statut,
    required this.dateDemande,
    this.niveau,
    this.centreNom,
    this.preuveTitre,
    this.preuveUrl,
    this.preuveDescription,
    this.commentaire,
  });

  final String id;
  final String citoyenNom;
  final String competenceNom;

  /// VALIDATION_PRATIQUE, PORTFOLIO_MEDIA ou MAITRE_ARTISAN.
  final String type;

  /// EN_ATTENTE, APPROUVEE ou REJETEE.
  final String statut;
  final DateTime dateDemande;
  final String? niveau;
  final String? centreNom;
  final String? preuveTitre;
  final String? preuveUrl;
  final String? preuveDescription;
  final String? commentaire;

  bool get enAttente => statut == 'EN_ATTENTE';
  bool get portfolio => type == 'PORTFOLIO_MEDIA';

  String get typeLabel => switch (type) {
    'VALIDATION_PRATIQUE' => 'Évaluation pratique',
    'PORTFOLIO_MEDIA' => 'Évaluation sur portfolio',
    'MAITRE_ARTISAN' => 'Évaluation par un maître artisan',
    _ => 'Évaluation',
  };

  String get niveauLabel => niveauDe(niveau);

  static String niveauDe(String? code) => switch (code) {
    'DEBUTANT' => 'Débutant',
    'INTERMEDIAIRE' => 'Intermédiaire',
    'EXPERT' => 'Expert',
    _ => 'Non précisé',
  };

  factory DemandeEvaluation.fromJson(Map<String, dynamic> j) {
    String? texte(String cle) {
      final v = j[cle]?.toString();
      return v == null || v.trim().isEmpty ? null : v;
    }

    final nom = '${j['citoyenPrenom'] ?? ''} ${j['citoyenNom'] ?? ''}'.trim();
    return DemandeEvaluation(
      id: (j['id'] ?? '').toString(),
      citoyenNom: nom.isEmpty ? 'Citoyen' : nom,
      competenceNom: texte('competenceNom') ?? 'Compétence',
      type: (j['type'] ?? '').toString(),
      statut: (j['statut'] ?? '').toString(),
      dateDemande:
          DateTime.tryParse((j['dateDemande'] ?? '').toString()) ??
          DateTime.fromMillisecondsSinceEpoch(0),
      niveau: texte('niveauCompetence'),
      centreNom: texte('centreNom'),
      preuveTitre: texte('preuveTitre'),
      preuveUrl: texte('preuveUrl'),
      preuveDescription: texte('preuveDescription'),
      commentaire: texte('commentaire'),
    );
  }
}
