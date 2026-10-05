import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_models.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_repository.dart';

/// Données fictives réalistes pour les opportunités au Mali.
class MockOpportuniteRepository implements OpportuniteRepository {
  const MockOpportuniteRepository();

  static final List<Opportunite> _items = _initial();

  static List<Opportunite> _initial() => [
        Opportunite(
          id: 'opp-1',
          title: 'Formation pratique en Énergies Solaires et Photovoltaïque',
          description:
              'Programme intensif de 3 mois financé par le FAFPA et le Ministère de l\'Emploi. Destiné aux jeunes artisans et techniciens électriciens désireux de se spécialiser dans le dimensionnement et l\'installation de centrales solaires à Bamako et Koulikoro.',
          type: OpportuniteType.formationGratuite,
          status: OpportuniteStatus.publiee,
          publishedAt: DateTime.now().subtract(const Duration(days: 3)),
          categoryId: 'cat-energie',
          categoryName: 'Énergie & Environnement',
          expirationDate: DateTime.now().add(const Duration(days: 28)),
          externalUrl: 'https://fafpa.gov.ml/programmes/solaire-2026',
        ),
        Opportunite(
          id: 'opp-2',
          title: 'Bourse d\'excellence pour l\'Artisanat et Métiers d\'Art',
          description:
              'Bourse d\'appui à l\'outillage et au perfectionnement technique pour les artisans menuisiers, tisserands et forgerons de la région de Ségou et Sikasso. Prise en charge des équipements et tutorat par des maîtres artisans.',
          type: OpportuniteType.bourse,
          status: OpportuniteStatus.publiee,
          publishedAt: DateTime.now().subtract(const Duration(days: 5)),
          categoryId: 'cat-artisanat',
          categoryName: 'Artisanat & Métiers d\'Art',
          expirationDate: DateTime.now().add(const Duration(days: 45)),
          externalUrl: 'https://artisanat.ml/bourses-2026',
        ),
        Opportunite(
          id: 'opp-3',
          title: 'Programme d\'Insertion Professionnelle des Jeunes (APEJ)',
          description:
              'Mise en stage pré-embauche et accompagnement vers l\'auto-emploi dans les filières BTP (maçonnerie, plomberie, électricité bâtiment) dans le District de Bamako. Indemnité mensuelle garantie.',
          type: OpportuniteType.programme,
          status: OpportuniteStatus.publiee,
          publishedAt: DateTime.now().subtract(const Duration(days: 7)),
          categoryId: 'cat-btp',
          categoryName: 'Bâtiment et Travaux Publics',
          expirationDate: DateTime.now().add(const Duration(days: 15)),
          externalUrl: 'https://apej.ml/insertion-btp',
        ),
        Opportunite(
          id: 'opp-4',
          title: 'Appel à candidatures : Salon National de la Transformation Agroalimentaire',
          description:
              'Sélection de 50 micro-entrepreneurs et transformatrices agroalimentaires (mangue, karité, céréales locales) pour exposer gratuitement au Parc des Expositions de Bamako avec accès direct aux acheteurs internationaux.',
          type: OpportuniteType.appelCandidature,
          status: OpportuniteStatus.publiee,
          publishedAt: DateTime.now().subtract(const Duration(days: 10)),
          categoryId: 'cat-agro',
          categoryName: 'Agroalimentaire',
          expirationDate: DateTime.now().add(const Duration(days: 12)),
          externalUrl: 'https://salon-agro.ml/candidatures',
        ),
        Opportunite(
          id: 'opp-5',
          title: 'Concours de l\'Innovation Numérique et Mobile au Mali',
          description:
              'Prix national récompensant les solutions technologiques adaptées aux réalités locales : santé, éducation rurale et commerce de proximité. Subvention de démarrage jusqu\'à 5 000 000 FCFA.',
          type: OpportuniteType.concours,
          status: OpportuniteStatus.publiee,
          publishedAt: DateTime.now().subtract(const Duration(days: 14)),
          categoryId: 'cat-num',
          categoryName: 'Technologies & Numérique',
          expirationDate: DateTime.now().add(const Duration(days: 30)),
          externalUrl: 'https://innovmali.org/concours',
        ),
        Opportunite(
          id: 'opp-6',
          title: 'Incubation et Accompagnement de Projets Agricoles Durables',
          description:
              'Accompagnement personnalisé pour maraîchers et éleveurs de la zone périurbaine de Kati et Sikasso. Diagnostic de terrain, optimisation de l\'irrigation et mise en réseau avec les coopératives.',
          type: OpportuniteType.accompagnement,
          status: OpportuniteStatus.publiee,
          publishedAt: DateTime.now().subtract(const Duration(days: 20)),
          categoryId: 'cat-agro',
          categoryName: 'Agriculture & Élevage',
          expirationDate: DateTime.now().add(const Duration(days: 60)),
        ),
        Opportunite(
          id: 'opp-7',
          title: 'Stage d\'insertion en Mécanique et Électromécanique',
          description:
              'Opportunité de perfectionnement pratique auprès des garages partenaires de Bamako. Ouvert aux titulaires d\'un CAP ou ayant validé leurs compétences pratiques.',
          type: OpportuniteType.insertion,
          status: OpportuniteStatus.publiee,
          publishedAt: DateTime.now().subtract(const Duration(days: 25)),
          categoryId: 'cat-meca',
          categoryName: 'Mécanique',
          expirationDate: DateTime.now().add(const Duration(days: 20)),
        ),
      ];

  static void resetForTests() => _items
    ..clear()
    ..addAll(_initial());

  Future<void> _latency([int ms = 300]) =>
      Future<void>.delayed(Duration(milliseconds: ms));

  @override
  Future<List<Opportunite>> list({
    OpportuniteType? type,
    String? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    await _latency(350);

    // Filtre sur les opportunités visibles (publiées et non expirées)
    var filtered = _items.where((o) => o.isVisible);

    if (type != null) {
      filtered = filtered.where((o) => o.type == type);
    }

    if (categoryId != null && categoryId.isNotEmpty) {
      filtered = filtered.where((o) => o.categoryId == categoryId);
    }

    final sorted = filtered.toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return sorted.skip(page * size).take(size).toList();
  }

  @override
  Future<Opportunite> get(String id) async {
    await _latency(250);
    if (id == 'error-network') throw const NetworkFailure();
    if (id == 'error-server') throw const ServerFailure();

    return _items.firstWhere(
      (o) => o.id == id,
      orElse: () => throw const NotFoundFailure(),
    );
  }
}
