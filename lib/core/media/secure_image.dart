import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/app/config/app_config.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';

/// Les fichiers du serveur (photo de profil, preuves, portfolio) sont privés : ils exigent le jeton
/// de connexion et leur adresse est relative (« /api/v1/portfolio-medias/… »). Une simple
/// NetworkImage ne peut donc pas les afficher : on les télécharge avec le client authentifié.

/// Chemin d'API protégé, ou null pour une image publique externe.
String? cheminApiProtege(String url) {
  final uri = Uri.tryParse(url.trim());
  if (uri == null) return null;
  if (!uri.hasScheme) return uri.path.startsWith('/api/') ? uri.toString() : null;
  final base = Uri.tryParse(AppConfig.apiBaseUrl);
  if (base != null && uri.origin == base.origin && uri.path.startsWith('/api/')) return uri.toString();
  return null;
}

/// Octets d'une image protégée (null si absente, refusée ou illisible).
/// Une photo qui pose problème ne doit jamais bloquer l'écran ni déconnecter l'utilisateur :
/// on renvoie null et l'icône par défaut s'affiche.
final imageProtegeeProvider = FutureProvider.autoDispose.family<Uint8List?, String>((ref, chemin) async {
  try {
    final res = await ref.read(dioProvider).get<List<int>>(
          chemin,
          options: Options(
            responseType: ResponseType.bytes,
            headers: {'Accept': 'image/*'},
            extra: {AuthInterceptor.sansDeconnexion: true},
            receiveTimeout: const Duration(seconds: 15),
          ),
        );
    final data = res.data;
    if (data == null || data.isEmpty) return null;
    final octets = Uint8List.fromList(data);
    // Vérifie que ce sont bien les octets d'une image (sinon l'affichage lèverait une exception).
    final codec = await ui.instantiateImageCodec(octets, targetWidth: 256);
    try {
      final image = (await codec.getNextFrame()).image;
      image.dispose();
    } finally {
      codec.dispose();
    }
    return octets;
  } catch (_) {
    return null;
  }
});

/// ImageProvider prêt à afficher pour [url] : octets chargés pour une image du serveur,
/// NetworkImage pour une image publique, null tant que rien n'est disponible.
ImageProvider? imageDepuisUrl(WidgetRef ref, String? url) {
  if (url == null || url.trim().isEmpty) return null;
  if (url.startsWith('data:')) {
    final data = Uri.tryParse(url)?.data;
    return data == null ? null : MemoryImage(data.contentAsBytes());
  }
  final chemin = cheminApiProtege(url);
  if (chemin == null) {
    final uri = Uri.tryParse(url);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https') ? NetworkImage(url) : null;
  }
  final octets = ref.watch(imageProtegeeProvider(chemin)).value;
  return octets == null ? null : MemoryImage(octets);
}
