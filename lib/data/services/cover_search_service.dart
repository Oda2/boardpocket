import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Why a cover search produced nothing usable.
enum CoverSearchFailure {
  /// Every source answered, but none had a match.
  none,

  /// No source could be reached.
  offline,

  /// A source asked us to slow down.
  rateLimited,
}

class CoverSearchException implements Exception {
  final CoverSearchFailure failure;
  final int? statusCode;

  const CoverSearchException(this.failure, [this.statusCode]);

  @override
  String toString() =>
      'CoverSearchException(${failure.name}${statusCode == null ? '' : ' ($statusCode)'})';
}

/// A cover image candidate returned by the online search.
///
/// Everything is remote: the app stores the URL and lets the platform fetch it,
/// so no image is ever downloaded or re-encoded.
class CoverImageResult {
  /// Small preview, safe to render in a grid.
  final String thumbnailUrl;

  /// Original image. This is what gets stored on the game.
  final String imageUrl;

  final String title;

  /// `Openverse`, `Wikimedia Commons` or `Wikipedia`.
  final String source;

  /// Page describing the image and its license, when known.
  final String? attributionUrl;

  const CoverImageResult({
    required this.thumbnailUrl,
    required this.imageUrl,
    required this.title,
    required this.source,
    this.attributionUrl,
  });

  @override
  bool operator ==(Object other) =>
      other is CoverImageResult &&
      other.thumbnailUrl == thumbnailUrl &&
      other.imageUrl == imageUrl &&
      other.title == title &&
      other.source == source;

  @override
  int get hashCode => Object.hash(thumbnailUrl, imageUrl, title, source);
}

/// Outcome of a search.
class CoverSearchResult {
  final List<CoverImageResult> items;

  /// True when the original query had to be shortened to find anything. Those
  /// results are less specific and the UI says so.
  final bool relaxed;

  /// The query actually used, which differs from the user's when [relaxed].
  final String usedQuery;

  const CoverSearchResult(
    this.items, {
    this.relaxed = false,
    this.usedQuery = '',
  });
}

/// Searches free, key-less APIs for board game cover references.
///
/// Sources (no account, no API key):
///  * Openverse           - https://api.openverse.org/v1/images
///  * Wikimedia Commons   - https://commons.wikimedia.org/w/api.php
///  * Wikipedia pageimages- https://{lang}.wikipedia.org/w/api.php
///
/// These are Creative Commons / public domain repositories of *photos*, not a
/// board game catalogue, so they are a visual reference at best.
class CoverSearchService {
  static const Duration _timeout = Duration(seconds: 12);

  /// Wikimedia API etiquette: identify the app. Ignored by browsers, which
  /// set their own User-Agent, but honoured on mobile and desktop.
  static const String _userAgent =
      'BoardPocket/0.1.5 (https://github.com/Oda2/boardpocket)';

  /// Wikipedia editions searched, in priority order.
  static const List<String> _wikiLangs = ['pt', 'en'];

  final http.Client _client;

  CoverSearchService({http.Client? client}) : _client = client ?? http.Client();

  /// Searches all sources for [query].
  ///
  /// Sources are independent: one failing never discards the others' results.
  /// If the full query has no matches, shorter variants are tried before giving
  /// up, because these APIs match on *all* words ("dixit disney" finds
  /// nothing while "dixit" finds plenty).
  ///
  /// Throws [CoverSearchException] only when no source could be reached.
  Future<CoverSearchResult> search(String query, {int limit = 24}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const CoverSearchResult([]);

    CoverSearchFailure? failure;
    var anyResponded = false;

    for (final candidate in queryVariants(trimmed)) {
      final attempt = await _searchAllSources(candidate, limit);

      if (attempt.items.isNotEmpty) {
        return CoverSearchResult(
          attempt.items,
          relaxed: candidate != trimmed,
          usedQuery: candidate,
        );
      }

      if (attempt.failure != null) failure ??= attempt.failure;

      // Keep relaxing even when a source answered: "no match" is exactly the
      // case where a shorter query helps.
      if (attempt.anyResponded) anyResponded = true;
    }

    // Every variant was tried. If any source ever answered, "nothing found" is
    // a real answer and one flaky source must not turn it into an outage.
    if (anyResponded) {
      return CoverSearchResult(const [], usedQuery: trimmed);
    }

    // No source ever answered on any variant: now it really is an error.
    throw CoverSearchException(failure ?? CoverSearchFailure.offline);
  }

  /// The query, then progressively shorter variants.
  ///
  /// "dixit disney" -> "dixit", because these APIs match on *every* word and
  /// "dixit disney" has no match anywhere while "dixit" does. Results found
  /// this way are flagged as [CoverSearchResult.relaxed] so the UI can say so.
  ///
  /// Public so the relaxation rules can be unit tested.
  static List<String> queryVariants(String query) {
    final words = query.split(RegExp(r'\s+'));
    if (words.length <= 1) return [query];
    return [
      for (var i = words.length; i >= 1; i--) words.sublist(0, i).join(' '),
    ];
  }

  Future<_Attempt> _searchAllSources(String query, int limit) async {
    final futures = [
      _guard(() => _searchOpenverse(query, limit), 'Openverse'),
      _guard(() => _searchCommons(query, limit), 'Wikimedia Commons'),
      _guard(() => _searchWikipedia(query, limit), 'Wikipedia'),
    ];

    final attempts = await Future.wait(futures);

    CoverSearchFailure? failure;
    var anyResponded = false;
    final buckets = <List<CoverImageResult>>[];

    for (final attempt in attempts) {
      buckets.add(attempt.items);
      if (attempt.failure == null) {
        anyResponded = true;
      } else {
        // Prefer the most actionable failure to report.
        failure ??= attempt.failure;
      }
    }

    return _Attempt(_interleave(buckets, limit), failure, anyResponded);
  }

  /// Round-robins across sources so no single one fills the whole page.
  ///
  /// Concatenating and then truncating meant Openverse's 24 results always
  /// filled the limit, and Wikipedia never showed up at all.
  static List<CoverImageResult> _interleave(
    List<List<CoverImageResult>> buckets,
    int limit,
  ) {
    final merged = <CoverImageResult>[];
    final seen = <CoverImageResult>{};

    for (var round = 0; merged.length < limit; round++) {
      var addedThisRound = false;
      for (final bucket in buckets) {
        if (round >= bucket.length) continue;
        final item = bucket[round];
        if (seen.add(item)) {
          merged.add(item);
          addedThisRound = true;
          if (merged.length >= limit) break;
        }
      }
      // Every bucket is exhausted.
      if (!addedThisRound) break;
    }

    return merged;
  }

  /// Runs one source, converting *any* error into a failed attempt.
  ///
  /// Without this a timeout or a malformed body from a single source would
  /// take down the whole search, which is what made the UI claim there was no
  /// internet even when other sources had answered fine.
  Future<_Attempt> _guard(
    Future<List<CoverImageResult>> Function() body,
    String name,
  ) async {
    try {
      return _Attempt(await body(), null, true);
    } on CoverSearchException catch (e) {
      return _Attempt(const [], e.failure, false);
    } catch (e) {
      debugPrint('CoverSearch: $name failed: $e');
      return _Attempt(const [], CoverSearchFailure.offline, false);
    }
  }

  Future<http.Response> _get(Uri uri) async {
    final response = await _client
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
            'User-Agent': _userAgent,
          },
        )
        .timeout(_timeout);

    if (response.statusCode == 429) {
      throw const CoverSearchException(CoverSearchFailure.rateLimited, 429);
    }
    if (response.statusCode != 200) {
      throw CoverSearchException(
        CoverSearchFailure.offline,
        response.statusCode,
      );
    }
    return response;
  }

  Future<List<CoverImageResult>> _searchOpenverse(
    String query,
    int limit,
  ) async {
    final uri = Uri.https('api.openverse.org', '/v1/images/', {
      'q': query,
      'page_size': '$limit',
      'mature': 'false',
    });

    final body = _decode(await _get(uri));
    final raw = body['results'];
    if (raw is! List) return const [];

    final results = <CoverImageResult>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final url = entry['url'];
      if (url is! String || url.isEmpty) continue;
      final thumb = entry['thumbnail'];

      results.add(
        CoverImageResult(
          thumbnailUrl: thumb is String && thumb.isNotEmpty ? thumb : url,
          imageUrl: url,
          title: _cleanTitle(entry['title'] as String?),
          source: 'Openverse',
          attributionUrl: entry['foreign_landing_url'] as String?,
        ),
      );
    }
    return results;
  }

  Future<List<CoverImageResult>> _searchCommons(String query, int limit) async {
    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'format': 'json',
      'origin': '*',
      'generator': 'search',
      'gsrsearch': '$query filetype:bitmap',
      'gsrnamespace': '6',
      'gsrlimit': '$limit',
      'prop': 'imageinfo',
      'iiprop': 'url|mime',
      'iiurlwidth': '400',
    });

    final body = _decode(await _get(uri));
    final pages = (body['query'] as Map?)?['pages'];
    if (pages is! Map) return const [];

    final results = <CoverImageResult>[];
    for (final entry in pages.values) {
      if (entry is! Map) continue;
      final info = entry['imageinfo'];
      if (info is! List || info.isEmpty) continue;
      final first = info.first;
      if (first is! Map) continue;

      final mime = first['mime'];
      if (mime != 'image/jpeg' && mime != 'image/png') continue;

      final url = first['url'];
      if (url is! String || url.isEmpty) continue;
      final thumb = first['thumburl'];

      results.add(
        CoverImageResult(
          thumbnailUrl: thumb is String && thumb.isNotEmpty ? thumb : url,
          imageUrl: url,
          title: _cleanTitle(entry['title'] as String?),
          source: 'Wikimedia Commons',
          attributionUrl: entry['imageinfoUrl'] as String?,
        ),
      );
    }
    return results;
  }

  /// Lead image of the Wikipedia article for the game.
  ///
  /// This is the closest thing to a real box cover these free APIs offer: for
  /// most notable board games the article's lead image *is* the cover.
  /// `pilicense=free` skips articles whose only image is non-free, which the
  /// API would not return anyway.
  Future<List<CoverImageResult>> _searchWikipedia(
    String query,
    int limit,
  ) async {
    final perLang = (limit / _wikiLangs.length).ceil().clamp(1, limit);

    final responses = await Future.wait([
      for (final lang in _wikiLangs)
        _guard(
          () => _searchWikipediaLang(lang, query, perLang),
          'Wikipedia/$lang',
        ),
    ]);

    final results = <CoverImageResult>[];
    CoverSearchFailure? failure;

    for (final attempt in responses) {
      results.addAll(attempt.items);
      if (attempt.failure != null && failure == null) {
        failure = attempt.failure;
      }
    }

    // Re-raise when every language failed, otherwise the outer guard sees a
    // clean return and treats Wikipedia as "responded with no results".
    if (results.isEmpty && failure != null) {
      throw CoverSearchException(failure);
    }

    return results;
  }

  Future<List<CoverImageResult>> _searchWikipediaLang(
    String lang,
    String query,
    int limit,
  ) async {
    final uri = Uri.https('$lang.wikipedia.org', '/w/api.php', {
      'action': 'query',
      'format': 'json',
      'origin': '*',
      'generator': 'search',
      'gsrsearch': query,
      'gsrlimit': '$limit',
      'prop': 'pageimages',
      'piprop': 'original|thumbnail',
      'pithumbsize': '400',
      'pilicense': 'free',
    });

    final body = _decode(await _get(uri));
    final pages = (body['query'] as Map?)?['pages'];
    if (pages is! Map) return const [];

    final results = <CoverImageResult>[];
    for (final entry in pages.values) {
      if (entry is! Map) continue;
      final images = entry['original'];
      if (images is! Map) continue;

      final url = images['source'];
      if (url is! String || url.isEmpty) continue;

      final thumb = images['thumburl'];
      final title = _cleanTitle(entry['title'] as String?);

      results.add(
        CoverImageResult(
          thumbnailUrl: thumb is String && thumb.isNotEmpty ? thumb : url,
          imageUrl: url,
          // The Wikipedia article name is a better label than the file name.
          title: title,
          source: 'Wikipedia ($lang)',
          attributionUrl:
              'https://$lang.wikipedia.org/wiki/${Uri.encodeComponent(title)}',
        ),
      );
    }
    return results;
  }

  Map<String, dynamic> _decode(http.Response response) {
    final body = jsonDecode(utf8.decode(response.bodyBytes));
    if (body is! Map<String, dynamic>) {
      throw const CoverSearchException(CoverSearchFailure.offline);
    }
    return body;
  }

  static String _cleanTitle(String? raw) {
    if (raw == null || raw.isEmpty) return 'Cover';
    return raw.replaceFirst(RegExp(r'^File:'), '').trim();
  }

  void dispose() => _client.close();
}

class _Attempt {
  final List<CoverImageResult> items;
  final CoverSearchFailure? failure;

  /// True when the source answered without error, even with zero results.
  final bool anyResponded;

  const _Attempt(this.items, this.failure, this.anyResponded);
}
