import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/network/page_utils.dart';
import 'package:mlc_mobile/features/admin/presentation/admin_providers.dart';
import 'package:mlc_mobile/features/evaluateur/domain/evaluateur_models.dart';

final evaluatorCentresProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final role = await ref.watch(currentRoleProvider.future);
      if (role != 'CITOYEN' && role != 'EVALUATEUR') {
        return <Map<String, dynamic>>[];
      }
      final response = await ref
          .watch(dioProvider)
          .get<dynamic>('/api/v1/evaluateur/mes-centres');
      final data = response.data;
      if (data is! List) return <Map<String, dynamic>>[];
      return data
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList();
    });

/// Compteur incrémenté à chaque décision : les listes de l'espace évaluateur se rechargent.
final evaluateurRevisionProvider = StateProvider<int>((ref) => 0);

Future<List<Map<String, dynamic>>> _lignes(Ref ref, String chemin) async {
  final response = await ref.watch(dioProvider).get<dynamic>(chemin);
  return pageItems(response.data)
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

/// Demandes en attente dans les centres de l'évaluateur.
final evaluateurDemandesProvider =
    FutureProvider.autoDispose<List<DemandeEvaluation>>((ref) async {
      ref.watch(evaluateurRevisionProvider);
      return (await _lignes(
        ref,
        '/api/v1/evaluateur/demandes',
      )).map(DemandeEvaluation.fromJson).toList();
    });

/// Décisions déjà rendues par les centres de l'évaluateur.
final evaluateurHistoriqueProvider =
    FutureProvider.autoDispose<List<DemandeEvaluation>>((ref) async {
      ref.watch(evaluateurRevisionProvider);
      return (await _lignes(
        ref,
        '/api/v1/evaluateur/historique',
      )).map(DemandeEvaluation.fromJson).toList();
    });

/// Réalisations du portfolio du citoyen dont l'évaluateur examine la demande.
final evaluateurPortfolioProvider = FutureProvider.autoDispose
    .family<List<Map<String, dynamic>>, String>(
      (ref, demandeId) =>
          _lignes(ref, '/api/v1/evaluateur/demandes/$demandeId/portfolio'),
    );
