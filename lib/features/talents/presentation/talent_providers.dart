import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/talents/data/api_talent_repository.dart';
import 'package:mlc_mobile/features/talents/data/mock_talent_repository.dart';
import 'package:mlc_mobile/features/talents/domain/talent_repository.dart';

final talentRepositoryProvider = Provider<TalentRepository>((ref) {
  return AppConfig.useMocks
      ? const MockTalentRepository()
      : ApiTalentRepository(ref.watch(dioProvider));
});

// TODO: ajouter ici les providers d'état de la fonctionnalité (FutureProvider.autoDispose pour les lectures,
// AutoDisposeAsyncNotifier pour les formulaires/actions) et les consommer dans les écrans de
// lib/features/talents/presentation/ avec AsyncValueView. Modèle : competences_providers.dart.
