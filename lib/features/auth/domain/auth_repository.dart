class RegisterData {
  const RegisterData({
    required this.nom,
    required this.prenom,
    required this.telephone,
    required this.password,
    this.email,
    this.communeId,
    this.sexe,
    this.conditionsAcceptees = false,
  });
  final String nom;
  final String prenom;
  final String telephone;
  final String password;
  final String? email;
  final String? communeId;

  /// Code API du sexe (FEMME / HOMME).
  final String? sexe;

  /// Acceptation explicite des conditions d'utilisation (exigée par le serveur).
  final bool conditionsAcceptees;
}

/// Contact vérifié par un code à 6 chiffres.
enum CanalVerification {
  telephone('TELEPHONE', 'Téléphone'),
  email('EMAIL', 'E-mail');

  const CanalVerification(this.api, this.libelle);

  /// Valeur échangée avec le serveur.
  final String api;
  final String libelle;

  static CanalVerification? fromApi(Object? v) {
    for (final c in values) {
      if (c.api == v) return c;
    }
    return null;
  }
}

abstract interface class AuthRepository {
  /// [identifiant] = téléphone ou email. Enregistre les jetons en stockage sécurisé.
  Future<void> login({required String identifiant, required String password});

  /// Crée le compte (bloqué) et renvoie les contacts à vérifier. Aucune session n'est ouverte :
  /// elle démarre avec [verifyOtp].
  Future<List<CanalVerification>> register(RegisterData data);

  /// Vérifie le téléphone ou l'e-mail avec le code reçu, ouvre le compte et enregistre les jetons.
  Future<void> verifyOtp({
    required String identifiant,
    required CanalVerification canal,
    required String code,
  });

  /// Nouveau code (le serveur impose une minute entre deux envois).
  Future<void> resendOtp({required String identifiant, required CanalVerification canal});

  Future<void> logout();
  Future<void> requestPasswordReset(String identifiant);
  /// [identifiant] = téléphone ou email saisi à l'étape « mot de passe oublié » (le serveur en a besoin pour retrouver le compte).
  Future<void> resetPassword({
    required String identifiant,
    required String code,
    required String newPassword,
  });
}
