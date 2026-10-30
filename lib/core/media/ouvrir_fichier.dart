import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/media/secure_image.dart';
import 'package:mlc_mobile/core/network/dio_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

/// Ouvre un document privé du serveur (PDF, Word…) avec l'application de l'appareil.
/// Le fichier exige le jeton de connexion : il est téléchargé avec le client authentifié,
/// copié dans le dossier temporaire, puis confié au système. Lève une [AppFailure] lisible.
Future<void> ouvrirFichierProtege(WidgetRef ref, String url, {String? nom}) async {
  final chemin = cheminApiProtege(url);
  if (chemin == null) {
    throw const FeatureUnavailableFailure("Ce document n'est pas disponible.");
  }
  final res = await guardDio(() => ref.read(dioProvider).get<List<int>>(
        chemin,
        options: Options(
          responseType: ResponseType.bytes,
          extra: {AuthInterceptor.sansDeconnexion: true},
          receiveTimeout: const Duration(seconds: 60),
        ),
      ));
  final octets = res.data;
  if (octets == null || octets.isEmpty) {
    throw const FeatureUnavailableFailure("Ce document est vide ou introuvable.");
  }
  final dossier = await getTemporaryDirectory();
  final propre = (nom == null || nom.trim().isEmpty ? 'document' : nom).replaceAll(RegExp(r'[^\w.\-]+'), '_');
  final fichier = File('${dossier.path}/$propre');
  await fichier.writeAsBytes(octets, flush: true);
  final resultat = await OpenFilex.open(fichier.path);
  if (resultat.type != ResultType.done) {
    throw const FeatureUnavailableFailure("Aucune application de l'appareil ne peut ouvrir ce document.");
  }
}
