import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/portfolio/data/api_portfolio_repository.dart';
import 'package:mlc_mobile/features/portfolio/data/mock_portfolio_repository.dart';
import 'package:mlc_mobile/features/portfolio/domain/portfolio_repository.dart';

final portfolioRepositoryProvider = Provider<PortfolioRepository>((ref) {
  return AppConfig.useMocks
      ? const MockPortfolioRepository()
      : ApiPortfolioRepository(ref.watch(dioProvider));
});

// TODO: ajouter ici les providers d'état de la fonctionnalité (FutureProvider.autoDispose pour les lectures,
// AutoDisposeAsyncNotifier pour les formulaires/actions) et les consommer dans les écrans de
// lib/features/portfolio/presentation/ avec AsyncValueView. Modèle : competences_providers.dart.
