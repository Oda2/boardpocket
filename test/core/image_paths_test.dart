import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/utils/image_paths.dart';

void main() {
  group('isRemoteImagePath', () {
    test('detects https urls', () {
      expect(isRemoteImagePath('https://images.example/cover.jpg'), isTrue);
    });

    test('detects http urls', () {
      expect(isRemoteImagePath('http://images.example/cover.jpg'), isTrue);
    });

    test('is case insensitive on the scheme', () {
      expect(isRemoteImagePath('HTTPS://images.example/cover.jpg'), isTrue);
    });

    test('detects blob urls used by the web picker', () {
      expect(isRemoteImagePath('blob:http://localhost/abc-123'), isTrue);
    });

    test('detects data urls', () {
      expect(isRemoteImagePath('data:image/png;base64,iVBOR'), isTrue);
    });

    test('returns false for a local file path', () {
      expect(
        isRemoteImagePath('/data/user/0/com.oda2.boardpocket/x.jpg'),
        isFalse,
      );
    });

    test('returns false for an empty path', () {
      expect(isRemoteImagePath(''), isFalse);
    });

    test('does not treat a relative path starting with http as remote', () {
      expect(isRemoteImagePath('/http_stub/cover.jpg'), isFalse);
    });
  });
}
