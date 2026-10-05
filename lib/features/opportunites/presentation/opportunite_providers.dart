import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/opportunites/data/api_opportunite_repository.dart';
import 'package:mlc_mobile/features/opportunites/data/mock_opportunite_repository.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_repository.dart';

final opportuniteRepositoryProvider = Provider<OpportuniteRepository>((ref) {
  return AppConfig.useMocks
      ? const MockOpportuniteRepository()
      : ApiOpportuniteRepository(ref.watch(dioProvider));
});

// TODO: ajouter ici les providers d'état de la fonctionnalité (FutureProvider.autoDispose pour les lectures,
// AutoDisposeAsyncNotifier pour les formulaires/actions) et les consommer dans les écrans de
// lib/features/opportunites/presentation/ avec AsyncValueView. Modèle : competences_providers.dart.
