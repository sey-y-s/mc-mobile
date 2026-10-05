import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/network/api_endpoints.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:mlc_mobile/core/security/current_user_id.dart';
import 'package:mlc_mobile/core/storage/token_storage.dart';
import 'package:mlc_mobile/features/parametres/domain/settings_models.dart';
import 'package:mlc_mobile/features/parametres/domain/settings_repository.dart';

class ApiSettingsRepository implements SettingsRepository {
  const ApiSettingsRepository(this._dio, this._storage);
  final Dio _dio;
  final TokenStorage _storage;
  Future<String> get _userId => requireCurrentUserId(_storage);

  @override
  Future<UserAccount> account() async {
    final uid = await _userId;
    final res = await guardDio(
      () => _dio.get<Map<String, dynamic>>(ApiEndpoints.mobileUser(uid)),
    );
    return UserAccount.fromJson(res.data!);
  }

  @override
  Future<UserAccount> updateAccount(AccountChanges changes) async {
    try {
      final uid = await _userId;
      final res = await guardDio(
        () => _dio.put<Map<String, dynamic>>(
          ApiEndpoints.mobileUserContact(uid),
          data: {
            'telephone': changes.telephone.trim(),
            'email': changes.email?.trim(),
          },
        ),
      );
      return UserAccount.fromJson(res.data!);
    } on NotFoundFailure {
      throw const FeatureUnavailableFailure(
        "La modification sécurisée des coordonnées n'est pas encore disponible sur le serveur.",
      );
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final uid = await _userId;
      await guardDio(
        () => _dio.put<void>(
          ApiEndpoints.mobilePasswordChange,
          data: {
            'utilisateurId': uid,
            'ancienMotDePasse': currentPassword,
            'nouveauMotDePasse': newPassword,
          },
        ),
      );
    } on NotFoundFailure {
      throw const FeatureUnavailableFailure(
        'Le changement de mot de passe doit être ajouté au serveur.',
      );
    }
  }

  @override
  Future<AppPreferences> loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return AppPreferences(
      lowDataMode: prefs.getBool('settings.low_data') ?? false,
      notificationsEnabled: prefs.getBool('settings.notifications') ?? true,
    );
  }

  @override
  Future<void> savePreferences(AppPreferences preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('settings.low_data', preferences.lowDataMode);
    await prefs.setBool(
      'settings.notifications',
      preferences.notificationsEnabled,
    );
  }
}
