import 'dart:convert';

class JwtUtils {
  const JwtUtils._();

  /// Lecture de `exp` côté client UNIQUEMENT pour éviter un appel inutile.
  /// Le serveur reste l'autorité : un jeton illisible n'est pas considéré expiré (le 401 décidera).
  static bool isExpired(String token, {DateTime? now}) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return false;
      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final exp = (jsonDecode(payload) as Map<String, dynamic>)['exp'];
      if (exp is! int) return false;
      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000, isUtc: true);
      return (now ?? DateTime.now().toUtc()).isAfter(expiry);
    } catch (_) {
      return false;
    }
  }
}
