import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/parcours_validation/data/api_parcours_validation_repository.dart';
import 'package:mlc_mobile/features/parcours_validation/data/mock_parcours_validation_repository.dart';
import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_models.dart';
import 'package:mlc_mobile/features/parcours_validation/domain/parcours_validation_repository.dart';

final parcoursValidationRepositoryProvider = Provider<ParcoursValidationRepository>(
  (ref) => AppConfig.useMocks
      ? const MockParcoursValidationRepository()
      : ApiParcoursValidationRepository(ref.watch(dioProvider)),
);

/// Parcours de validation d'une compétence du citoyen (identifiant de la compétence du citoyen).
final parcoursValidationProvider = FutureProvider.autoDispose.family<ParcoursValidation, String>(
  (ref, citoyenCompetenceId) => ref.watch(parcoursValidationRepositoryProvider).get(citoyenCompetenceId),
);
