import 'package:geolocator/geolocator.dart';

/// Erreur lisible pour l'utilisateur lors de la lecture de la position.
class PositionIndisponible implements Exception {
  const PositionIndisponible(this.message, {this.ouvrirReglages = false});
  final String message;
  final bool ouvrirReglages;
  @override
  String toString() => message;
}

/// Précision minimale exigée pour proposer une commune (en mètres).
const precisionMaxMetres = 1000.0;

/// Lit la position UNE fois (pas de suivi en continu). Elle sert seulement à déterminer la commune :
/// elle n'est ni conservée dans l'application, ni enregistrée par le serveur.
Future<({double latitude, double longitude})> lirePositionUneFois({
  bool demanderPermission = true,
}) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const PositionIndisponible(
      'La localisation de votre téléphone est désactivée. Activez-la puis réessayez.',
    );
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied && demanderPermission) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    throw const PositionIndisponible(
      "L'accès à la position est bloqué. Autorisez-le dans les réglages.",
      ouvrirReglages: true,
    );
  }
  if (permission == LocationPermission.denied) {
    throw const PositionIndisponible(
      "Vous n'avez pas autorisé l'accès à la position.",
    );
  }
  final pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      // Les communes d'une même ville sont distantes de quelques kilomètres : on demande une bonne précision.
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
    ),
  );
  // Un navigateur ou un ordinateur donne souvent une position approchée (adresse IP, Wi-Fi) à plusieurs
  // kilomètres : elle tomberait dans la mauvaise commune. Mieux vaut laisser le citoyen choisir.
  if (pos.accuracy > precisionMaxMetres) {
    throw const PositionIndisponible(
      'Votre position est trop imprécise pour deviner votre commune.',
    );
  }
  return (latitude: pos.latitude, longitude: pos.longitude);
}
