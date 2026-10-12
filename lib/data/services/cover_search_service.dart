import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

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

  /// `Openverse` or `Wikimedia Commons`.
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

/// Searches free, key-less image APIs for board game cover references.
///
/// Sources (both require no account and no API key):
///  * Openverse       - https://api.openverse.org/v1/images/
///  * Wikimedia Commons - https://commons.wikimedia.org/w/api.php
///
/// The results are meant as a visual reference, not as an official box scan.
class CoverSearchService {
  static const Duration _timeout = Duration(seconds: 12);

  final http.Client _client;

  CoverSearchService({http.Client? client}) : _client = client ?? http.Client();

  /// Returns up to [limit] results, merging both sources.
  ///
  /// One source failing does not break the search: whatever came back is
  /// returned. Throws only when every source failed.
  Future<List<CoverImageResult>> search(String query, {int limit = 24}) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const [];

    final responses = await Future.wait([
      _searchOpenverse(trimmed, limit),
      _searchWikimedia(trimmed, limit),
    ]);

    final merged = <CoverImageResult>[];
    Object? firstError;

    for (final (items, error) in responses) {
      if (error != null) {
        firstError ??= error;
        continue;
      }
      for (final item in items) {
        if (!merged.contains(item)) merged.add(item);
      }
    }

    if (merged.isEmpty && firstError != null) throw firstError;

    return merged.take(limit).toList();
  }

  Future<(List<CoverImageResult>, Object?)> _searchOpenverse(
    String query,
    int limit,
  ) async {
    final uri = Uri.https('api.openverse.org', '/v1/images/', {
      'q': query,
      'page_size': '$limit',
      'mature': 'false',
    });

    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(_timeout);

    if (response.statusCode != 200) {
      return (
        const <CoverImageResult>[],
        StateError('Openverse returned ${response.statusCode}'),
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map) {
      return (
        const <CoverImageResult>[],
        StateError('Unexpected Openverse payload'),
      );
    }

    final raw = body['results'];
    if (raw is! List) return (const <CoverImageResult>[], null);

    final results = <CoverImageResult>[];
    for (final entry in raw) {
      if (entry is! Map) continue;
      final url = entry['url'];
      final thumb = entry['thumbnail'];
      if (url is! String || url.isEmpty) continue;

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
    return (results, null);
  }

  Future<(List<CoverImageResult>, Object?)> _searchWikimedia(
    String query,
    int limit,
  ) async {
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

    final response = await _client
        .get(uri, headers: const {'Accept': 'application/json'})
        .timeout(_timeout);

    if (response.statusCode != 200) {
      return (
        const <CoverImageResult>[],
        StateError('Wikimedia returned ${response.statusCode}'),
      );
    }

    final body = jsonDecode(response.body);
    if (body is! Map) return (const <CoverImageResult>[], null);

    final queryBlock = body['query'];
    if (queryBlock is! Map) return (const <CoverImageResult>[], null);

    final pages = queryBlock['pages'];
    if (pages is! Map) return (const <CoverImageResult>[], null);

    final results = <CoverImageResult>[];
    for (final entry in pages.values) {
      if (entry is! Map) continue;

      final info = entry['imageinfo'];
      if (info is! List || info.isEmpty) continue;
      final first = info.first;
      if (first is! Map) continue;
      if (first['mime'] != 'image/jpeg' && first['mime'] != 'image/png') {
        continue;
      }

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
    return (results, null);
  }

  static String _cleanTitle(String? raw) {
    if (raw == null || raw.isEmpty) return 'Cover';
    // Wikimedia prefixes file entries with "File:".
    return raw.replaceFirst(RegExp(r'^File:'), '').trim();
  }

  void dispose() => _client.close();
}
