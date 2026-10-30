import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/network/page_utils.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_models.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_repository.dart';

class ApiOpportuniteRepository implements OpportuniteRepository {
  const ApiOpportuniteRepository(this._dio);
  final Dio _dio;

  bool _affichable(Opportunite item) => item.isVisible && item.type != OpportuniteType.insertion;

  /// Liste « pour moi » (citoyen) : déjà triée par proximité. Repli sur la liste publique sinon.
  Future<List<Opportunite>> _all() async {
    try {
      final response = await guardDio(() => _dio.get<dynamic>(ApiEndpoints.mobileOpportunitiesForMe));
      return pageItems(response.data)
          .whereType<Map>()
          .map((item) => Opportunite.fromPourMoi(Map<String, dynamic>.from(item)))
          .where(_affichable)
          .toList();
    } on ForbiddenFailure {
      // Compte non citoyen (administration) : liste publique.
    } on NotFoundFailure {
      // Serveur sans la route « pour moi ».
    }
    final response = await guardDio(() => _dio.get<dynamic>(ApiEndpoints.mobileOpportunities));
    return pageItems(response.data)
        .whereType<Map>()
        .map((item) => Opportunite.fromJson(Map<String, dynamic>.from(item)))
        .where(_affichable)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  List<Opportunite> _page(List<Opportunite> items, int page, int size) {
    if (page < 0 || size <= 0) throw ValidationFailure();
    final start = page * size;
    if (start >= items.length) return const [];
    return items.skip(start).take(size).toList();
  }

  @override
  Future<List<Opportunite>> list({
    OpportuniteType? type,
    String? categoryId,
    bool presDeChezMoi = false,
    int page = 0,
    int size = 20,
  }) async {
    final filtered = (await _all())
        .where(
          (item) =>
              (type == null || item.type == type) &&
              (categoryId == null || item.categoryId == categoryId) &&
              (!presDeChezMoi || (item.proximite?.estLocale ?? false)),
        )
        .toList();
    return _page(filtered, page, size);
  }

  @override
  Future<Opportunite> get(String id) async {
    // La liste « pour moi » apporte la proximité et l'état de la candidature.
    for (final item in await _all()) {
      if (item.id == id) return item;
    }
    final response = await guardDio(
      () => _dio.get<Map<String, dynamic>>(ApiEndpoints.mobileOpportunity(id)),
    );
    final item = Opportunite.fromJson(response.data!);
    if (!_affichable(item)) throw const NotFoundFailure();
    return item;
  }

  @override
  Future<void> postuler(String id, {String? message}) async {
    await guardDio(
      () => _dio.post<dynamic>(
        ApiEndpoints.mobileOpportunityApply(id),
        data: {if (message != null && message.trim().isNotEmpty) 'message': message.trim()},
      ),
    );
  }
}
