import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/mise_en_relation/data/api_mise_en_relation_repository.dart';
import 'package:mlc_mobile/features/mise_en_relation/data/mock_mise_en_relation_repository.dart';
import 'package:mlc_mobile/features/mise_en_relation/domain/mise_en_relation_repository.dart';

final miseEnRelationRepositoryProvider =
    Provider<MiseEnRelationRepository>((ref) {
  return AppConfig.useMocks
      ? const MockMiseEnRelationRepository()
      : ApiMiseEnRelationRepository(ref.watch(dioProvider));
});

// TODO: ajouter ici les providers d'état de la fonctionnalité (FutureProvider.autoDispose pour les lectures,
// AutoDisposeAsyncNotifier pour les formulaires/actions) et les consommer dans les écrans de
// lib/features/mise_en_relation/presentation/ avec AsyncValueView. Modèle : competences_providers.dart.
