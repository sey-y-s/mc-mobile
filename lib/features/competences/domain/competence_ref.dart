import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';

/// Compétence du référentiel national (ce que le citoyen peut choisir d'ajouter).
/// [parcoursPossibles] : secteurs par lesquels elle peut s'acquérir (ex. la science
/// des données ne s'apprend que dans le secteur formel).
class CompetenceRef {
  const CompetenceRef({
    required this.id,
    required this.nom,
    this.secteurNom,
    this.metierNom,
    this.parcoursPossibles = Parcours.values,
  });
  final String id;
  final String nom;
  final String? secteurNom;
  final String? metierNom;
  final List<Parcours> parcoursPossibles;

  factory CompetenceRef.fromJson(Map<String, dynamic> j) => CompetenceRef(
        id: j['id'] as String,
        nom: j['nom'] as String,
        secteurNom: j['secteurNom'] as String?,
        metierNom: j['metierNom'] as String?,
        parcoursPossibles: Parcours.listFromApi(j['parcoursPossibles']),
      );
}
