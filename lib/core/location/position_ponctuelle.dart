import 'package:geolocator/geolocator.dart';

/// Erreur lisible pour l'utilisateur lors de la lecture de la position.
class PositionIndisponible implements Exception {
  const PositionIndisponible(this.message, {this.ouvrirReglages = false});
  final String message;
  final bool ouvrirReglages;
  @override
  String toString() => message;
}

/// Lit la position UNE fois (pas de suivi en continu). Elle sert seulement à déterminer la commune :
/// elle n'est ni conservée dans l'application, ni enregistrée par le serveur.
Future<({double latitude, double longitude})> lirePositionUneFois({bool demanderPermission = true}) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    throw const PositionIndisponible('La localisation de votre téléphone est désactivée. Activez-la puis réessayez.');
  }
  var permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied && demanderPermission) {
    permission = await Geolocator.requestPermission();
  }
  if (permission == LocationPermission.deniedForever) {
    throw const PositionIndisponible("L'accès à la position est bloqué. Autorisez-le dans les réglages.", ouvrirReglages: true);
  }
  if (permission == LocationPermission.denied) {
    throw const PositionIndisponible("Vous n'avez pas autorisé l'accès à la position.");
  }
  final pos = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      // Une précision moyenne suffit pour trouver une commune.
      accuracy: LocationAccuracy.medium,
      timeLimit: Duration(seconds: 20),
    ),
  );
  return (latitude: pos.latitude, longitude: pos.longitude);
}
