class ApiEndpoints {
  const ApiEndpoints._();

  /// Alias provisoire éviter de stocker l'id citoyen
  static const String me = 'me';

  static const String auth = '/api/v1/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String verifyOtp = '$auth/verify-otp';
  static const String resendOtp = '$auth/resend-otp';
  static const String logout = '$auth/logout';
  static const String refresh = '$auth/refresh';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';

  static const String citoyens = '/api/v1/citoyens';
  static String citoyen(String id) => '$citoyens/$id';
  static String citoyenCompetences(String id) => '$citoyens/$id/competences';
  static String citoyenExperiences(String id) => '$citoyens/$id/experiences';
  static String citoyenPortfolio(String id) => '$citoyens/$id/portfolio';

  static String citoyenPhoto(String id) => '/api/v1/citoyens/$id/photo';
  static String citoyenCv(String id) => '/api/v1/citoyens/$id/cv';
  static const String regions = '/api/v1/regions';

  /// Géolocalisation du citoyen connecté (GET / PUT / DELETE).
  /// Commune de référence, consentement et détection ponctuelle (aucune position n'est stockée).
  static const String citoyenMaLocalisation =
      '/api/v1/citoyens/me/localisation';
  static const String citoyenMesContestations =
      '/api/v1/citoyens/me/contestations';
  static String commune(String id) => '$communes/$id';
  static String preuve(String id) => '/api/v1/preuves/$id';
  static String citoyenValidations(String id) =>
      '/api/v1/citoyens/$id/validations';
  static String validation(String id) => '/api/v1/validations/$id';

  static const String organisations = '/api/v1/organisations';
  static const String centres = '/api/v1/centres';
  static const String competences = '/api/v1/competences';
  static const String communes = '/api/v1/communes';

  /// Détection de la commune à l'inscription (publique, la position n'est pas conservée).
  static const String detectionTerritoire = '/api/v1/territoires/detection';
  static String citoyenRegionCommunes(String regionId) =>
      '$communes/region/$regionId';

  static String preuves(String citoyenCompetenceId) =>
      '/api/v1/citoyen-competences/$citoyenCompetenceId/preuves';

  /// Dépôt d'une preuve avec fichier (multipart) : route dédiée côté serveur.
  /// L'ancienne route /api/v1/... n'accepte que du JSON : le serveur répondait 415,
  /// transformé en 401, ce qui déconnectait l'utilisateur après l'ajout d'une preuve.
  static String preuveFichier(String citoyenCompetenceId) =>
      '/api/v1/citoyens/me/citoyen-competences/$citoyenCompetenceId/preuves';

  /// Secteur formel / informel d'une compétence du citoyen (PATCH {parcours}).
  static String citoyenCompetenceParcours(String citoyenCompetenceId) =>
      '/api/v1/citoyen-competences/$citoyenCompetenceId/parcours';
  static String validations(String citoyenCompetenceId) =>
      '/api/v1/citoyen-competences/$citoyenCompetenceId/validations';

  /// Validations d'une compétence, lues par le citoyen propriétaire.
  static String citoyenCompetenceValidations(String citoyenCompetenceId) =>
      '/api/v1/citoyens/me/citoyen-competences/$citoyenCompetenceId/validations';

  /// Parcours de validation recommandé pour une compétence du citoyen (moteur d'orientation).
  static String parcoursValidation(String citoyenCompetenceId) =>
      '/api/v1/parcours-validation/competences/$citoyenCompetenceId';

  static const String besoins = '/api/v1/besoins';
  static const String demandesMiseEnRelation =
      '/api/v1/demandes-mise-en-relation';
  static const String opportunites = '/api/v1/opportunites';
  static const String skillsGap = '/api/v1/indicateurs/skills-gap';

  // ==========================================
  // --- Notifications Endpoints ---
  // ==========================================

  // ==========================================
  // --- Opportunites Endpoints ---
  // ==========================================
  static String opportunite(String id) => '$opportunites/$id';

  // Fonctionnalités mobiles (routes confirmées et routes provisoires signalées dans docs/CONTRAT_API_PROVISOIRE.md).
  static const String mobileNotifications = '/api/v1/notifications';
  static String mobileUserNotifications(String userId) =>
      '$mobileNotifications/utilisateur/$userId';
  static String mobileUnreadNotifications(String userId) =>
      '${mobileUserNotifications(userId)}/non-lues';
  static String mobileMarkNotificationRead(String recipientLinkId) =>
      '$mobileNotifications/$recipientLinkId/marquer-lue';

  static const String mobileOpportunities = '/api/v1/opportunites';

  /// Opportunités du citoyen connecté, avec proximité et candidature.
  static const String mobileOpportunitiesForMe =
      '/api/v1/opportunites/pour-moi';
  static String mobileOpportunityApply(String id) =>
      '/api/v1/opportunites/$id/candidatures';
  static String mobileOpportunity(String id) => '$mobileOpportunities/$id';

  static const String mobileTalentSearch = '/api/v1/talents/recherche';
  static String mobileAnonymizedTalent(String id) => '/api/v1/talents/$id';

  static const String mobileRelations = '/api/v1/demandes-mise-en-relation';
  static String mobileRelation(String id) => '$mobileRelations/$id';

  /// Demandes reçues par le citoyen connecté.
  static const String mobileMyRelations = '$mobileRelations/mes-demandes';

  /// Réponse du citoyen (ACCEPTEE / REFUSEE).
  static String mobileRelationAnswer(String id) =>
      '$mobileRelations/$id/reponse';

  static const String mobileTests = '/api/v1/tests-numeriques';
  static const String admin = '/api/v1/admin';
  static String adminDashboard() => '$admin/dashboard';
  static String adminUsers() => '$admin/users';
  static String adminUserRole(String id) => '$admin/users/$id/role';
  static String adminValidations() => '$admin/validations';
  static String adminValidationStatus(String id) =>
      '$admin/validations/$id/statut';
  static String adminTests() => '$admin/tests-numeriques';
  static String adminTest(String id) => '$admin/tests-numeriques/$id';
  static String adminOpportunities() => '$admin/opportunites';
  static String adminOpportunity(String id) => '$opportunites/$id';
  static const String opportunityCategories = '/api/v1/categories-opportunites';
  static const String adminCompetences = '$admin/competences';
  static String mobileTestsForCompetence(String competenceId) =>
      '$mobileTests/competence/$competenceId';
  static String mobileTest(String id) => '$mobileTests/$id';
  static String mobileTestQuestions(String id) => '${mobileTest(id)}/questions';
  static String mobileQuestionOptions(String questionId) =>
      '$mobileTests/questions/$questionId/propositions';
  static String mobileTestResults(String testId) =>
      '${mobileTest(testId)}/resultats';
  static String mobileCitizenTestResults(String citizenId) =>
      '$mobileTests/resultats/citoyen/$citizenId';
  static String mobileCitizenCompetences(String citizenId) =>
      '/api/v1/citoyens/$citizenId/competences';

  static String mobilePortfolio(String citizenId) =>
      '/api/v1/citoyens/$citizenId/portfolio';
  static String mobilePortfolioItem(String citizenId, String id) =>
      '${mobilePortfolio(citizenId)}/$id';
  static String mobilePortfolioMediaUpload(String realisationId) =>
      '/api/v1/portfolio-realisations/$realisationId/medias';
  static String mobilePortfolioMedia(String realisationId, String mediaId) =>
      '/api/v1/portfolio-realisations/$realisationId/medias/$mediaId';

  static String mobileUser(String userId) => '/api/v1/utilisateurs/$userId';
  static String mobileUserContact(String userId) =>
      '/api/v1/utilisateurs/$userId/contact';
  static const String mobileUserPreferences =
      '/api/v1/utilisateurs/me/preferences';
  static const String mobilePasswordChange = '/api/v1/auth/mot-de-passe';
}
