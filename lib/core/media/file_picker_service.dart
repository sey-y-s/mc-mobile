import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mlc_mobile/core/errors/app_failure.dart';
import 'package:mlc_mobile/core/media/picked_media.dart';

/// Abstraction de la sélection de fichiers : l'écran ne connaît pas les plugins,
/// et les tests injectent un faux service (voir filePickerServiceProvider).
abstract interface class FilePickerService {
  /// Retourne null si l'utilisateur annule. Lève [FileFailure] si l'accès est refusé.
  Future<PickedMedia?> pick(PickSource source);
}

class DevicePickerService implements FilePickerService {
  DevicePickerService({ImagePicker? imagePicker}) : _images = imagePicker ?? ImagePicker();
  final ImagePicker _images;

  @override
  Future<PickedMedia?> pick(PickSource source) async {
    try {
      switch (source) {
        case PickSource.camera:
          return await _fromXFile(await _images.pickImage(source: ImageSource.camera, maxWidth: 1600, maxHeight: 1600, imageQuality: 70), MediaKind.image);
        case PickSource.gallery:
          return await _fromXFile(await _images.pickImage(source: ImageSource.gallery, maxWidth: 1600, maxHeight: 1600, imageQuality: 70), MediaKind.image);
        case PickSource.video:
          return await _fromXFile(await _images.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 1)), MediaKind.video);
        case PickSource.document:
          // Appel direct sans .platform
          final file = await FilePicker.pickFile(
            type: FileType.custom,
            allowedExtensions: const ['pdf', 'doc', 'docx'],
          );
          if (file == null || file.path == null) return null;
          
          final sizeBytes = file.lengthSync() ?? await file.length() ?? 0;

          return PickedMedia(
            path: file.path!,
            name: file.name,
            sizeBytes: sizeBytes,
            kind: MediaKind.document,
          );
      }
    } on PlatformException catch (e) {
      throw FileFailure(_messageFor(e.code));
    }
  }

  Future<PickedMedia?> _fromXFile(XFile? f, MediaKind kind) async =>
      f == null ? null : PickedMedia(path: f.path, name: f.name, sizeBytes: await f.length(), kind: kind);

  String _messageFor(String code) => code.contains('denied')
      ? "Autorisez l'accès à la caméra ou aux photos dans les réglages du téléphone."
      : "Impossible d'ouvrir le fichier. Réessayez.";
}

final filePickerServiceProvider = Provider<FilePickerService>((ref) => DevicePickerService());