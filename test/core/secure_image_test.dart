import 'package:flutter_test/flutter_test.dart';
import 'package:mlc_mobile/core/media/secure_image.dart';

void main() {
  test('une photo du serveur (adresse relative) est chargée avec le jeton', () {
    expect(cheminApiProtege('/api/v1/portfolio-medias/abc.jpg'), '/api/v1/portfolio-medias/abc.jpg');
  });

  test('une image publique externe reste une simple image réseau', () {
    expect(cheminApiProtege('https://exemple.org/photo.jpg'), isNull);
    expect(cheminApiProtege('photo.jpg'), isNull);
  });
}
