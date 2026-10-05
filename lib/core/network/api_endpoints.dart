class ApiEndpoints {
  const ApiEndpoints._();

  /// Alias provisoire éviter de stocker l'id citoyen
  static const String me = 'me';

  static const String auth = '/api/auth';
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
  static String citoyenDisponibilite(String id) => '$citoyens/$id/disponibilite'; 
  static String citoyenPhoto(String id) => '$citoyens/$id/photo'; 
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

  static String preuves(String citoyenCompetenceId) => '/api/citoyen-competences/$citoyenCompetenceId/preuves';
  static String validations(String citoyenCompetenceId) => '/api/citoyen-competences/$citoyenCompetenceId/validations';

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
  static const String notificationsUnreadCount = '$notifications/non-lues/count';
  static String citoyenNotifications(String id) => '$citoyens/$id/notifications';

  // ==========================================
  // --- Opportunites Endpoints ---
  // ==========================================
  static String opportunite(String id) => '$opportunites/$id';
}