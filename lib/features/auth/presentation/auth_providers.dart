import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/security/session.dart';
import 'package:mlc_mobile/features/auth/data/api_auth_repository.dart';
import 'package:mlc_mobile/features/auth/data/mock_auth_repository.dart';
import 'package:mlc_mobile/features/auth/domain/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(tokenStorageProvider);
  return AppConfig.useMocks
      ? MockAuthRepository(storage)
      : ApiAuthRepository(ref.watch(dioProvider), storage);
});

/// Inscription ou connexion en attente du code de vérification (gardée en mémoire seulement).
class VerificationEnCours {
  const VerificationEnCours({
    required this.identifiant,
    required this.canaux,
    required this.codeDejaEnvoye,
  });
  final String identifiant;
  final List<CanalVerification> canaux;

  /// Vrai juste après l'inscription (le code vient de partir) ; faux depuis la connexion (on en redemande un).
  final bool codeDejaEnvoye;
}

class VerificationNotifier extends Notifier<VerificationEnCours?> {
  @override
  VerificationEnCours? build() => null;
  void definir(VerificationEnCours v) => state = v;
  void effacer() => state = null;
}

final verificationProvider =
    NotifierProvider<VerificationNotifier, VerificationEnCours?>(
      VerificationNotifier.new,
    );

/// État d'une action d'authentification (login/register/logout) : loading / error / data.
class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> login(String identifiant, String password) async {
    final ok = await _run(
      () => ref
          .read(authRepositoryProvider)
          .login(identifiant: identifiant, password: password),
    );
    // Mot de passe correct mais compte non vérifié : on prépare l'écran du code.
    if (!ok && state.error is AccountNotVerifiedFailure) {
      final estEmail = identifiant.contains('@');
      ref
          .read(verificationProvider.notifier)
          .definir(
            VerificationEnCours(
              identifiant: identifiant,
              canaux: [
                estEmail
                    ? CanalVerification.email
                    : CanalVerification.telephone,
              ],
              codeDejaEnvoye: false,
            ),
          );
    }
    return ok;
  }

  /// Crée le compte (bloqué). Succès = l'écran du code doit s'ouvrir ; aucune session n'est ouverte.
  Future<bool> register(RegisterData data) async {
    List<CanalVerification> canaux = const [];
    final ok = await _run(() async {
      canaux = await ref.read(authRepositoryProvider).register(data);
    }, ouvreSession: false);
    if (ok) {
      ref
          .read(verificationProvider.notifier)
          .definir(
            VerificationEnCours(
              identifiant: data.telephone,
              canaux: canaux,
              codeDejaEnvoye: true,
            ),
          );
    }
    return ok;
  }

  /// Bon code : le compte s'ouvre et la session démarre (le routeur ouvre l'accueil).
  Future<bool> verifyOtp({
    required String identifiant,
    required CanalVerification canal,
    required String code,
  }) async {
    final ok = await _run(
      () => ref
          .read(authRepositoryProvider)
          .verifyOtp(identifiant: identifiant, canal: canal, code: code),
    );
    if (ok) ref.read(verificationProvider.notifier).effacer();
    return ok;
  }

  Future<void> logout() async {
    // La révocation côté serveur démarre d'abord (elle lit les jetons tout de suite), mais on ne l'attend pas :
    // la session locale se ferme immédiatement, même si le serveur est lent ou injoignable.
    final serveur = ref.read(authRepositoryProvider).logout();
    await ref.read(sessionProvider.notifier).expire();
    unawaited(serveur.then((_) {}, onError: (_) {}));
  }

  Future<bool> _run(
    Future<void> Function() action, {
    bool ouvreSession = true,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    if (state.hasError) return false;
    if (ouvreSession) ref.read(sessionProvider.notifier).setAuthenticated();
    return true;
  }
}

final authControllerProvider =
    AsyncNotifierProvider.autoDispose<AuthController, void>(AuthController.new);
