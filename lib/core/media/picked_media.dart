enum MediaKind { image, video, document }

/// D'où vient le fichier : détermine l'écran système ouvert.
enum PickSource { camera, gallery, video, document }

/// Fichier choisi par l'utilisateur (déjà compressé si c'est une image).
class PickedMedia {
  const PickedMedia({required this.path, required this.name, required this.sizeBytes, required this.kind});
  final String path;
  final String name;
  final int sizeBytes;
  final MediaKind kind;

  String get sizeLabel => formatBytes(sizeBytes);
}

/// Tailles maximales par type (low-data). Les images sont compressées à la prise (1600 px, qualité 70).
class FileLimits {
  const FileLimits({this.imageBytes = 1024 * 1024, this.documentBytes = 3 * 1024 * 1024, this.videoBytes = 10 * 1024 * 1024});
  final int imageBytes;
  final int documentBytes;
  final int videoBytes;

  int maxBytesFor(MediaKind kind) => switch (kind) {
        MediaKind.image => imageBytes,
        MediaKind.document => documentBytes,
        MediaKind.video => videoBytes,
      };
}

/// « 820 Ko », « 1,2 Mo » (français).
String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes o';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).round()} Ko';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1).replaceAll('.', ',')} Mo';
}
