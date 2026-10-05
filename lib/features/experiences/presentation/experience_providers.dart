import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/experiences/data/api_experience_repository.dart';
import 'package:mlc_mobile/features/experiences/data/mock_experience_repository.dart';
import 'package:mlc_mobile/features/experiences/domain/experience_repository.dart';

final experienceRepositoryProvider = Provider<ExperienceRepository>((ref) {
  return AppConfig.useMocks
      ? const MockExperienceRepository()
      : ApiExperienceRepository(ref.watch(dioProvider));
});

// TODO: ajouter ici les providers d'état de la fonctionnalité (FutureProvider.autoDispose pour les lectures,
// AutoDisposeAsyncNotifier pour les formulaires/actions) et les consommer dans les écrans de
// lib/features/experiences/presentation/ avec AsyncValueView. Modèle : competences_providers.dart.
