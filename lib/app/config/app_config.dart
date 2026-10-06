/// Configuration par environnement, injectée à la compilation :
/// `flutter run --dart-define-from-file=config/dev.json`
/// Aucun secret ici : uniquement des valeurs publiques (URL, drapeaux).
enum AppEnv { dev, test, prod }

class AppConfig {
  const AppConfig._();

  static const String _envName = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );
  static const bool _useMocksFlag = bool.fromEnvironment(
    'USE_MOCKS',
    defaultValue: false,
  );

  static AppEnv get env => AppEnv.values.firstWhere(
    (e) => e.name == _envName,
    orElse: () => AppEnv.dev,
  );

  /// Les mocks sont impossibles en production, quoi qu'il arrive.
  static bool get useMocks => env != AppEnv.prod && _useMocksFlag;
}
