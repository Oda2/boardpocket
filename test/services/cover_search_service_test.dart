import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:boardpocket/data/services/cover_search_service.dart';

/// Minimal http.Client stub that answers per host with a fixed payload.
class _FakeClient extends http.BaseClient {
  _FakeClient(this.openverse, this.wikimedia);

  final Object openverse;
  final Object wikimedia;
  final List<Uri> requested = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;
    requested.add(uri);
    final payload = uri.host.contains('openverse') ? openverse : wikimedia;

    final status = payload is _Failure ? payload.statusCode : 200;
    final body = payload is _Failure ? '' : jsonEncode(payload);

    return http.StreamedResponse(
      Stream.value(utf8.encode(body)),
      status,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _Failure {
  const _Failure(this.statusCode);
  final int statusCode;
}

const _openversePayload = {
  'results': [
    {
      'url': 'https://images.example/catan_full.jpg',
      'thumbnail': 'https://images.example/catan_thumb.jpg',
      'title': 'Catan box',
      'foreign_landing_url': 'https://example.com/photo',
    },
    {
      // No thumbnail provided: the full image should be used instead.
      'url': 'https://images.example/ticket.jpg',
      'title': 'Ticket to Ride',
    },
    {'title': 'missing url, should be skipped'},
  ],
};

const _wikimediaPayload = {
  'query': {
    'pages': {
      '1': {
        'title': 'File:Catan cover.jpg',
        'imageinfo': [
          {
            'url': 'https://upload.wikimedia.org/catan.jpg',
            'thumburl': 'https://upload.wikimedia.org/catan_thumb.jpg',
            'mime': 'image/jpeg',
          },
        ],
      },
      '2': {
        'title': 'File:Skipped.gif',
        'imageinfo': [
          {'url': 'https://upload.wikimedia.org/skip.gif', 'mime': 'image/gif'},
        ],
      },
      '3': {'title': 'File:No info.jpg'},
    },
  },
};

void main() {
  group('CoverSearchService', () {
    test('returns results from both sources', () async {
      final service = CoverSearchService(
        client: _FakeClient(_openversePayload, _wikimediaPayload),
      );

      final results = await service.search('catan');

      // 2 valid Openverse + 1 valid Wikimedia (gif and info-less entries skipped).
      expect(results.length, 3);
      expect(
        results.map((r) => r.source),
        containsAll(['Openverse', 'Wikimedia Commons']),
      );
    });

    test('maps Openverse fields', () async {
      final service = CoverSearchService(
        client: _FakeClient(_openversePayload, const {}),
      );

      final results = await service.search('catan');
      final catan = results.firstWhere((r) => r.title == 'Catan box');

      expect(catan.imageUrl, 'https://images.example/catan_full.jpg');
      expect(catan.thumbnailUrl, 'https://images.example/catan_thumb.jpg');
      expect(catan.attributionUrl, 'https://example.com/photo');
    });

    test('falls back to the full image when no thumbnail exists', () async {
      final service = CoverSearchService(
        client: _FakeClient(_openversePayload, const {}),
      );

      final results = await service.search('catan');
      final ticket = results.firstWhere((r) => r.title == 'Ticket to Ride');

      expect(ticket.thumbnailUrl, 'https://images.example/ticket.jpg');
    });

    test('strips the Wikimedia File: prefix from titles', () async {
      final service = CoverSearchService(
        client: _FakeClient(const {}, _wikimediaPayload),
      );

      final results = await service.search('catan');

      expect(results.single.title, 'Catan cover.jpg');
    });

    test('skips Wikimedia entries that are not jpeg or png', () async {
      final service = CoverSearchService(
        client: _FakeClient(const {}, _wikimediaPayload),
      );

      final results = await service.search('catan');

      expect(results.any((r) => r.imageUrl.endsWith('.gif')), isFalse);
    });

    test('skips Openverse entries without a url', () async {
      final service = CoverSearchService(
        client: _FakeClient(_openversePayload, const {}),
      );

      final results = await service.search('catan');

      expect(results.length, 2);
    });

    test(
      'returns empty list for a blank query without hitting the network',
      () async {
        final client = _FakeClient(_openversePayload, _wikimediaPayload);
        final service = CoverSearchService(client: client);

        expect(await service.search('   '), isEmpty);
        expect(client.requested, isEmpty);
      },
    );

    test('sends the query to both APIs', () async {
      final client = _FakeClient(_openversePayload, _wikimediaPayload);
      final service = CoverSearchService(client: client);

      await service.search('ticket to ride');

      expect(client.requested.length, 2);
      expect(
        client.requested.map((u) => u.host),
        containsAll(['api.openverse.org', 'commons.wikimedia.org']),
      );
      expect(
        client.requested.every(
          (u) =>
              u.queryParameters['q'] != null ||
              u.queryParameters['gsrsearch'] != null,
        ),
        isTrue,
      );
    });

    test('still returns results when one source fails', () async {
      final service = CoverSearchService(
        client: _FakeClient(const _Failure(503), _wikimediaPayload),
      );

      final results = await service.search('catan');

      expect(results.length, 1);
      expect(results.single.source, 'Wikimedia Commons');
    });

    test('throws when both sources fail with a status error', () async {
      final service = CoverSearchService(
        client: _FakeClient(const _Failure(500), const _Failure(404)),
      );

      await expectLater(service.search('catan'), throwsA(isA<StateError>()));
    });

    test('throws when the network itself fails', () async {
      final service = CoverSearchService(client: _ThrowingClient());

      await expectLater(service.search('catan'), throwsA(isA<Exception>()));
    });

    test('respects the limit', () async {
      final service = CoverSearchService(
        client: _FakeClient(_openversePayload, _wikimediaPayload),
      );

      final results = await service.search('catan', limit: 2);

      expect(results.length, 2);
    });

    test('tolerates empty result sets from both sources', () async {
      final service = CoverSearchService(
        client: _FakeClient(const {'results': []}, const {}),
      );

      expect(await service.search('zzzz'), isEmpty);
    });

    test('tolerates malformed payloads', () async {
      final service = CoverSearchService(
        client: _FakeClient(const {'unexpected': true}, const {'x': 1}),
      );

      expect(await service.search('catan'), isEmpty);
    });
  });
}

class _ThrowingClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    throw Exception('network down');
  }
}
