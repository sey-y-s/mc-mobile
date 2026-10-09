class ApiEndpoints {
  const ApiEndpoints._();

  /// Alias provisoire éviter de stocker l'id citoyen
  static const String me = 'me';

  static const String auth = '/api/v1/auth';
  static const String login = '$auth/login';
  static const String register = '$auth/register';
  static const String logout = '$auth/logout';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';
  static const String refresh = '$auth/refresh';

  static const String citoyens = '/api/citoyens';
  static String citoyen(String id) => '$citoyens/$id';
  static String citoyenCompetences(String id) => '$citoyens/$id/competences';
  static String citoyenExperiences(String id) => '$citoyens/$id/experiences';
  static String citoyenPortfolio(String id) => '$citoyens/$id/portfolio';
  static const String talentsSearch = '$citoyens/recherche';

  static String citoyenCommune(String id) => '$citoyens/$id/commune';
  static String citoyenDisponibilite(String id) =>
      '$citoyens/$id/disponibilite';
  static String citoyenPhoto(String id) => '/api/v1/citoyens/$id/photo';
  static String citoyenCv(String id) => '/api/v1/citoyens/$id/cv';
  static const String regions = '/api/regions';
  static String citoyenPreuves(String id) => '$citoyens/$id/preuves';
  static String preuve(String id) => '/api/preuves/$id';
  static String citoyenValidations(String id) => '$citoyens/$id/validations';
  static String validation(String id) => '/api/validations/$id';

  static const String organisations = '/api/organisations';
  static const String centres = '/api/centres';
  static const String competences = '/api/competences';
  static const String secteurs = '/api/secteurs-activite';
  static const String metiers = '/api/metiers';
  static const String communes = '/api/communes';

  static String preuves(String citoyenCompetenceId) =>
      '/api/citoyen-competences/$citoyenCompetenceId/preuves';
  static String validations(String citoyenCompetenceId) =>
      '/api/citoyen-competences/$citoyenCompetenceId/validations';

  static const String tests = '/api/tests';
  static const String besoins = '/api/besoins';
  static const String suiviBesoinTalents = '/api/suivi-besoin-talents';
  static const String demandesMiseEnRelation = '/api/demandes-mise-en-relation';
  static const String consultations = '/api/consultations';
  static const String notifications = '/api/notifications';
  static const String opportunites = '/api/opportunites';
  static const String skillsGap = '/api/skills-gap';

  // ==========================================
  // --- Notifications Endpoints ---
  // ==========================================
  static String notification(String id) => '$notifications/$id';
  static String notificationRead(String id) => '$notifications/$id/lire';
  static const String notificationsReadAll = '$notifications/tout-lire';
  static const String notificationsUnreadCount =
      '$notifications/non-lues/count';
  static String citoyenNotifications(String id) =>
      '$citoyens/$id/notifications';

  // ==========================================
  // --- Opportunites Endpoints ---
  // ==========================================
  static String opportunite(String id) => '$opportunites/$id';

  // Fonctionnalités mobiles (routes confirmées et routes provisoires signalées dans docs/CONTRAT_API_PROVISOIRE.md).
  static const String mobileNotifications = '/api/notifications';
  static String mobileUserNotifications(String userId) =>
      '$mobileNotifications/utilisateur/$userId';
  static String mobileUnreadNotifications(String userId) =>
      mobileUserNotifications(userId) + '/non-lues';
  static String mobileMarkNotificationRead(String recipientLinkId) =>
      '$mobileNotifications/$recipientLinkId/marquer-lue';

  static const String mobileOpportunities = '/api/opportunites';
  static String mobileOpportunity(String id) => '$mobileOpportunities/$id';

  static const String mobileTalentSearch = '/api/v1/citoyens/recherche';
  static String mobileAnonymizedTalent(String id) => '$mobileTalentSearch/$id';
  static const String mobileMetiers = '/api/v1/metiers';

  static const String mobileRelations = '/api/demandes-mise-en-relation';
  static String mobileRelation(String id) => '$mobileRelations/$id';

  static const String mobileTests = '/api/v1/tests-numeriques';
  static const String admin = '/api/admin';
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
  static const String opportunityCategories = '/api/categories-opportunites';
  static const String adminCompetences = '$admin/competences';
  static String mobileTestsForCompetence(String competenceId) =>
      '$mobileTests/competence/$competenceId';
  static String mobileTest(String id) => '$mobileTests/$id';
  static String mobileTestQuestions(String id) => mobileTest(id) + '/questions';
  static String mobileQuestionOptions(String questionId) =>
      '$mobileTests/questions/$questionId/propositions';
  static String mobileTestResults(String testId) =>
      mobileTest(testId) + '/resultats';
  static String mobileCitizenTestResults(String citizenId) =>
      '$mobileTests/resultats/citoyen/$citizenId';
  static String mobileCitizenCompetences(String citizenId) =>
      '/api/v1/citoyens/$citizenId/competences';

  static String mobilePortfolio(String citizenId) =>
      '/api/v1/citoyens/$citizenId/portfolio';
  static String mobilePortfolioItem(String citizenId, String id) =>
      mobilePortfolio(citizenId) + '/$id';
  static String mobilePortfolioMediaUpload(String realisationId) =>
      '/api/v1/portfolio-realisations/$realisationId/medias';
  static String mobilePortfolioMedia(String realisationId, String mediaId) =>
      '/api/v1/portfolio-realisations/$realisationId/medias/$mediaId';

  static String mobileUser(String userId) => '/api/utilisateurs/$userId';
  static String mobileUserContact(String userId) =>
      '/api/utilisateurs/$userId/contact';
  static const String mobilePasswordChange = '/api/v1/auth/mot-de-passe';
}
