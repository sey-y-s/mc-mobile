import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/contestations/data/contestation_repository.dart';

final contestationRepositoryProvider = Provider<ContestationRepository>(
  (ref) => AppConfig.useMocks ? MockContestationRepository() : ApiContestationRepository(ref.watch(dioProvider)),
);

final mesContestationsProvider = FutureProvider.autoDispose<List<Contestation>>(
  (ref) => ref.watch(contestationRepositoryProvider).mesContestations(),
);
