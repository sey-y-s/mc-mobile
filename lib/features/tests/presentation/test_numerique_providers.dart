import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/tests/data/api_test_numerique_repository.dart';
import 'package:mlc_mobile/features/tests/data/mock_test_numerique_repository.dart';
import 'package:mlc_mobile/features/tests/domain/test_numerique_repository.dart';

final testNumeriqueRepositoryProvider =
    Provider<TestNumeriqueRepository>((ref) {
  return AppConfig.useMocks
      ? const MockTestNumeriqueRepository()
      : ApiTestNumeriqueRepository(ref.watch(dioProvider));
});

// TODO: ajouter ici les providers d'état de la fonctionnalité (FutureProvider.autoDispose pour les lectures,
// AutoDisposeAsyncNotifier pour les formulaires/actions) et les consommer dans les écrans de
// lib/features/tests/presentation/ avec AsyncValueView. Modèle : competences_providers.dart.
