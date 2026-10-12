import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:boardpocket/data/services/cover_search_service.dart';

/// Answers per host so each source can be stubbed independently.
class _FakeClient extends http.BaseClient {
  _FakeClient({
    this.openverse,
    this.commons,
    this.wikipedia,
    this.wikipediaMatching,
    this.defaultBody,
  });

  final Object? openverse;
  final Object? commons;
  final Object? wikipedia;

  /// Only returned when the query equals this exact string, so relaxation
  /// can be exercised.
  final Object? wikipediaMatching;
  final Object? defaultBody;

  final List<Uri> requested = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;
    requested.add(uri);

    if (uri.host.contains('openverse')) return _respond(openverse);

    if (uri.host.contains('commons')) return _respond(commons);

    final term = uri.queryParameters['gsrsearch'];
    if (wikipediaMatching != null && term == 'dixit') {
      return _respond(wikipediaMatching);
    }
    return _respond(wikipedia ?? defaultBody);
  }

  http.StreamedResponse _respond(Object? payload) {
    if (payload is _Failure) {
      return http.StreamedResponse(
        Stream.value(utf8.encode(payload.body)),
        payload.statusCode,
        headers: {'content-type': 'text/plain'},
      );
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(payload ?? const {}))),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

class _Failure {
  const _Failure(this.statusCode, [this.body = '']);
  final int statusCode;
  final String body;
}

/// Never answers, to simulate a dropped connection or a timeout.
class _BrokenClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) =>
      throw Exception('network down');
}

const _openverse = {
  'results': [
    {
      'url': 'https://images.example/catan_full.jpg',
      'thumbnail': 'https://images.example/catan_thumb.jpg',
      'title': 'Catan box',
      'foreign_landing_url': 'https://example.com/photo',
    },
    {
      // No thumbnail: the full image should be used instead.
      'url': 'https://images.example/ticket.jpg',
      'title': 'Ticket to Ride',
    },
    {'title': 'missing url, should be skipped'},
  ],
};

const _commons = {
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

const _wikipedia = {
  'query': {
    'pages': {
      '10': {
        'title': 'Dixit',
        'original': {
          'source': 'https://upload.wikimedia.org/dixit.jpg',
          'thumburl': 'https://upload.wikimedia.org/dixit_thumb.jpg',
        },
      },
      '11': {'title': 'No image here'},
    },
  },
};

CoverSearchService _serviceWith(_FakeClient client) =>
    CoverSearchService(client: client);

void main() {
  group('CoverSearchService', () {
    test('merges results from all three sources', () async {
      final service = _serviceWith(
        _FakeClient(
          openverse: _openverse,
          commons: _commons,
          wikipedia: _wikipedia,
        ),
      );

      final result = await service.search('catan');

      // 2 Openverse + 1 Commons + 1 Wikipedia per language (pt and en).
      expect(result.items.length, 5);
      expect(
        result.items.map((r) => r.source).toSet(),
        containsAll([
          'Openverse',
          'Wikimedia Commons',
          'Wikipedia (pt)',
          'Wikipedia (en)',
        ]),
      );
      expect(result.relaxed, isFalse);
    });

    test('maps Openverse fields', () async {
      final service = _serviceWith(_FakeClient(openverse: _openverse));

      final result = await service.search('catan');
      final catan = result.items.firstWhere((r) => r.title == 'Catan box');

      expect(catan.imageUrl, 'https://images.example/catan_full.jpg');
      expect(catan.thumbnailUrl, 'https://images.example/catan_thumb.jpg');
      expect(catan.attributionUrl, 'https://example.com/photo');
    });

    test('falls back to the full image when no thumbnail exists', () async {
      final service = _serviceWith(_FakeClient(openverse: _openverse));

      final result = await service.search('catan');
      final ticket = result.items.firstWhere(
        (r) => r.title == 'Ticket to Ride',
      );

      expect(ticket.thumbnailUrl, 'https://images.example/ticket.jpg');
    });

    test('skips Openverse entries without a url', () async {
      final service = _serviceWith(_FakeClient(openverse: _openverse));

      final result = await service.search('catan');

      expect(result.items.length, 2);
    });

    test('strips the Wikimedia File: prefix from titles', () async {
      final service = _serviceWith(_FakeClient(commons: _commons));

      final result = await service.search('catan');

      expect(result.items.single.title, 'Catan cover.jpg');
    });

    test('skips Wikimedia entries that are not jpeg or png', () async {
      final service = _serviceWith(_FakeClient(commons: _commons));

      final result = await service.search('catan');

      expect(result.items.any((r) => r.imageUrl.endsWith('.gif')), isFalse);
    });

    test('skips Wikipedia articles without an image', () async {
      final service = _serviceWith(
        _FakeClient(wikipedia: _wikipedia, defaultBody: const {}),
      );

      final result = await service.search('dixit');

      expect(result.items.every((r) => r.imageUrl.isNotEmpty), isTrue);
      expect(result.items.any((r) => r.title == 'No image here'), isFalse);
    });

    test(
      'returns an empty list for a blank query without hitting the network',
      () async {
        final client = _FakeClient(openverse: _openverse);
        final service = _serviceWith(client);

        final result = await service.search('   ');

        expect(result.items, isEmpty);
        expect(client.requested, isEmpty);
      },
    );

    test('sends the query to every source', () async {
      final client = _FakeClient(
        openverse: _openverse,
        commons: _commons,
        wikipedia: _wikipedia,
      );
      final service = _serviceWith(client);

      await service.search('ticket to ride');

      expect(
        client.requested.map((u) => u.host).toSet(),
        containsAll([
          'api.openverse.org',
          'commons.wikimedia.org',
          'pt.wikipedia.org',
          'en.wikipedia.org',
        ]),
      );
    });

    // --- the regression this rewrite exists for --------------------------

    test('keeps results from healthy sources when one throws', () async {
      // Openverse answers 500, the rest are fine. The old code let a single
      // failure abort everything, which the UI reported as "no internet".
      final service = _serviceWith(
        _FakeClient(
          openverse: const _Failure(500),
          commons: _commons,
          wikipedia: _wikipedia,
        ),
      );

      final result = await service.search('catan');

      expect(result.items, isNotEmpty);
      expect(result.items.map((r) => r.source), isNot(contains('Openverse')));
    });

    test('keeps results when one source sends a non-JSON body', () async {
      final service = _serviceWith(
        _FakeClient(
          openverse: const _Failure(200, '<html>maintenance</html>'),
          commons: _commons,
          wikipedia: _wikipedia,
        ),
      );

      final result = await service.search('catan');

      expect(result.items, isNotEmpty);
    });

    test('keeps results when the connection drops for one source', () async {
      final service = CoverSearchService(client: _BrokenClient());

      await expectLater(
        service.search('catan'),
        throwsA(
          isA<CoverSearchException>().having(
            (e) => e.failure,
            'failure',
            CoverSearchFailure.offline,
          ),
        ),
      );
    });

    test('reports rate limiting separately from being offline', () async {
      final service = _serviceWith(
        _FakeClient(
          openverse: const _Failure(429),
          commons: const _Failure(429),
          wikipedia: const _Failure(429),
        ),
      );

      await expectLater(
        service.search('catan'),
        throwsA(
          isA<CoverSearchException>().having(
            (e) => e.failure,
            'failure',
            CoverSearchFailure.rateLimited,
          ),
        ),
      );
    });

    test(
      'does not error when a rate-limited source is joined by a good one',
      () async {
        final service = _serviceWith(
          _FakeClient(
            openverse: const _Failure(429),
            commons: _commons,
            wikipedia: _wikipedia,
          ),
        );

        final result = await service.search('catan');

        expect(result.items, isNotEmpty);
      },
    );

    // --- no results vs no connection --------------------------------------

    test(
      'returns empty (not an error) when every source answers with nothing',
      () async {
        final service = _serviceWith(_FakeClient(defaultBody: const {}));

        final result = await service.search('zzzz');

        expect(result.items, isEmpty);
      },
    );

    test(
      'does not throw when one source fails but another has nothing either',
      () async {
        final service = _serviceWith(
          _FakeClient(openverse: const _Failure(500), defaultBody: const {}),
        );

        final result = await service.search('zzzz');

        expect(result.items, isEmpty);
      },
    );

    // --- query relaxation --------------------------------------------------

    test('relaxes a multi-word query that has no match', () async {
      // The Wikipedia stub only answers for "dixit", so the full query
      // "dixit disney" finds nothing anywhere and must fall back to "dixit".
      final client = _FakeClient(
        openverse: const {'results': []},
        commons: const {},
        wikipedia: const {},
        wikipediaMatching: _wikipedia,
      );
      final service = _serviceWith(client);

      final result = await service.search('dixit disney');

      expect(result.items, isNotEmpty);
      expect(result.relaxed, isTrue);
      expect(result.usedQuery, 'dixit');
    });

    test('stops relaxing once something is found', () async {
      final client = _FakeClient(
        openverse: _openverse,
        commons: _commons,
        wikipedia: _wikipedia,
      );
      final service = _serviceWith(client);

      final result = await service.search('dixit disney');

      // The full query matches, so no relaxation and no extra requests.
      expect(result.relaxed, isFalse);
      expect(result.usedQuery, 'dixit disney');
      expect(
        client.requested.every(
          (u) => u.queryParameters.containsKey('q')
              ? u.queryParameters['q'] == 'dixit disney'
              : u.queryParameters['gsrsearch']!.contains('dixit disney'),
        ),
        isTrue,
      );
    });

    test('relaxes all the way down to a single word', () {
      expect(CoverSearchService.queryVariants('a b c d'), [
        'a b c d',
        'a b c',
        'a b',
        'a',
      ]);
    });

    test('relaxes a two-word query to one word', () {
      expect(CoverSearchService.queryVariants('dixit disney'), [
        'dixit disney',
        'dixit',
      ]);
    });

    test('keeps the original query when it is a single word', () {
      expect(CoverSearchService.queryVariants('catan'), ['catan']);
    });

    test('respects the limit', () async {
      final service = _serviceWith(
        _FakeClient(
          openverse: _openverse,
          commons: _commons,
          wikipedia: _wikipedia,
        ),
      );

      final result = await service.search('catan', limit: 2);

      expect(result.items.length, 2);
    });

    test('tolerates malformed payloads', () async {
      final service = _serviceWith(
        _FakeClient(defaultBody: const {'unexpected': true}),
      );

      final result = await service.search('catan');

      expect(result.items, isEmpty);
    });
  });
}
