import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Copie locale des informations de base (profil, compétences…) pour les afficher sans réseau.
/// Contient des données personnelles : elle est vidée à chaque déconnexion ([clear]).
class LocalCache {
  const LocalCache._();
  static const _prefix = 'cache.';

  static Future<void> write(String key, Object? json) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_prefix$key', jsonEncode(json));
    } catch (_) {
      // Le cache est un confort : son échec ne doit jamais bloquer l'application.
    }
  }

  static Future<Object?> read(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_prefix$key');
      return raw == null ? null : jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  static Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final k
          in prefs.getKeys().where((k) => k.startsWith(_prefix)).toList()) {
        await prefs.remove(k);
      }
    } catch (_) {}
  }
}
