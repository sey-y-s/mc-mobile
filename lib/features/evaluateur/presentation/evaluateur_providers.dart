import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/features/admin/presentation/admin_providers.dart';

final evaluatorCentresProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final role = await ref.watch(currentRoleProvider.future);
  if (role != 'CITOYEN' && role != 'EVALUATEUR') return <Map<String, dynamic>>[];
  final response = await ref.watch(dioProvider).get<dynamic>('/api/v1/evaluateur/mes-centres');
  final data = response.data;
  if (data is! List) return <Map<String, dynamic>>[];
  return data.whereType<Map>().map((item) => Map<String, dynamic>.from(item)).toList();
});
