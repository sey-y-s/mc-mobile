import 'package:dio/dio.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/network/page_utils.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_models.dart';
import 'package:mlc_mobile/features/opportunites/domain/opportunite_repository.dart';

class ApiOpportuniteRepository implements OpportuniteRepository {
  const ApiOpportuniteRepository(this._dio);
  final Dio _dio;

  List<Opportunite> _list(dynamic body) => pageItems(body)
      .map((e) => Opportunite.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  Future<List<Opportunite>> list({
    OpportuniteType? type,
    String? categoryId,
    int page = 0,
    int size = 20,
  }) async {
    final query = <String, dynamic>{
      'page': page,
      'size': size,
      if (type != null) 'type': type.apiCode,
      if (categoryId != null && categoryId.isNotEmpty)
        'categoryId': categoryId,
    };

    final res = await guardDio(() => _dio.get<dynamic>(
          ApiEndpoints.opportunites,
          queryParameters: query,
        ));
    return _list(res.data);
  }

  @override
  Future<Opportunite> get(String id) async {
    final res = await guardDio(() =>
        _dio.get<Map<String, dynamic>>(ApiEndpoints.opportunite(id)));
    return Opportunite.fromJson(res.data!);
  }
}
