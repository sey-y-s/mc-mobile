import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/security/session.dart';
import 'package:mlc_mobile/features/competences/data/api_competences_repository.dart';
import 'package:mlc_mobile/features/competences/data/mock_competences_repository.dart';
import 'package:mlc_mobile/features/competences/domain/citoyen_competence.dart';
import 'package:mlc_mobile/features/competences/domain/competence_ref.dart';
import 'package:mlc_mobile/features/competences/domain/competences_repository.dart';

final competencesRepositoryProvider = Provider<CompetencesRepository>((ref) {
  return AppConfig.useMocks
      ? const MockCompetencesRepository()
      : ApiCompetencesRepository(
          ref.watch(dioProvider),
          ref.watch(tokenStorageProvider),
        );
});

// Toutes les compétences du citoyen (jusqu'à 100) : la liste sert aussi aux choix des preuves
// et des validations, qui ne doivent jamais en oublier.
final competencesProvider = FutureProvider.autoDispose<List<CitoyenCompetence>>(
  (ref) => ref.watch(competencesRepositoryProvider).list(size: 100),
);

final competenceDetailProvider =
    FutureProvider.autoDispose.family<CitoyenCompetence, String>(
  (ref, id) => ref.watch(competencesRepositoryProvider).get(id),
);

/// Recherche dans le référentiel avec anti-rebond (400 ms)
final referentielSearchProvider = FutureProvider.autoDispose
    .family<List<CompetenceRef>, String>((ref, query) async {
  var disposed = false;
  ref.onDispose(() => disposed = true);
  await Future<void>.delayed(const Duration(milliseconds: 400));
  if (disposed) return const <CompetenceRef>[];
  return ref.read(competencesRepositoryProvider).searchReferentiel(query);
});

class AddCompetenceController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  /// Retourne la compétence créée (null en cas d'échec ; la liste est alors rechargée).
  Future<CitoyenCompetence?> submit(
      {required CompetenceRef competence, required Niveau niveau, required Parcours parcours}) async {
    state = const AsyncLoading();
    CitoyenCompetence? created;
    state = await AsyncValue.guard<void>(() async {
      created = await ref
          .read(competencesRepositoryProvider)
          .add(competenceId: competence.id, niveau: niveau, parcours: parcours);
    });
    if (state.hasError) return null;
    ref.invalidate(competencesProvider);
    return created;
  }
}

final addCompetenceControllerProvider =
    AsyncNotifierProvider.autoDispose<AddCompetenceController, void>(
        AddCompetenceController.new);

/// Précise le secteur (formel / informel) d'une compétence existante.
class ParcoursController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<bool> submit(String citoyenCompetenceId, Parcours parcours) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard<void>(() async {
      await ref.read(competencesRepositoryProvider).setParcours(citoyenCompetenceId, parcours);
    });
    if (state.hasError) return false;
    ref.invalidate(competencesProvider);
    ref.invalidate(competenceDetailProvider(citoyenCompetenceId));
    return true;
  }
}

final parcoursControllerProvider =
    AsyncNotifierProvider.autoDispose<ParcoursController, void>(ParcoursController.new);