import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/services/store_search.dart';

void main() {
  group('StoreSearch URLs', () {
    test('google appends "board game" to the query', () {
      final uri = StoreSearch.google('Catan');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/search');
      expect(uri.queryParameters['q'], 'Catan board game');
    });

    test('amazon uses the Brazilian storefront by default', () {
      final uri = StoreSearch.amazon('Catan');
      expect(uri.host, 'www.amazon.com.br');
      expect(uri.path, '/s');
      expect(uri.queryParameters['k'], 'Catan');
    });

    test('amazon can target the US storefront', () {
      expect(StoreSearch.amazon('Catan', brazil: false).host, 'www.amazon.com');
    });

    test('mercado livre points at the Brazilian marketplace', () {
      final uri = StoreSearch.mercadoLivre('Catan');
      expect(uri.host, 'lista.mercadolivre.com.br');
      expect(uri.queryParameters['q'], 'Catan');
    });

    test('board game geek searches board games specifically', () {
      final uri = StoreSearch.boardGameGeek('Dixit');
      expect(uri.host, 'boardgamegeek.com');
      expect(uri.path, '/geeksearch.php');
      expect(uri.queryParameters['action'], 'search');
      expect(uri.queryParameters['objecttype'], 'boardgame');
      expect(uri.queryParameters['q'], 'Dixit');
    });

    test('every entry trims the title', () {
      for (final entry in StoreSearch.entries) {
        expect(entry.build('  Catan  ').query, isNot(contains('  ')));
      }
    });

    test('titles are url-encoded', () {
      final uri = StoreSearch.mercadoLivre('Jogo da Vida & Cia');
      expect(uri.toString(), contains('%26'));
      expect(uri.queryParameters['q'], 'Jogo da Vida & Cia');
    });

    test('accented titles survive the round trip', () {
      const title = 'Jogo da Vida — Êxtensão';
      expect(StoreSearch.google(title).queryParameters['q'], contains('Vida'));
      expect(StoreSearch.mercadoLivre(title).queryParameters['q'], title);
    });
  });

  group('StoreSearch.entries', () {
    test('offers the four storefronts', () {
      expect(
        StoreSearch.entries.map((e) => e.id),
        containsAll(['google', 'amazon', 'mercadolivre', 'bgg']),
      );
    });

    test('ids are unique', () {
      final ids = StoreSearch.entries.map((e) => e.id).toSet();
      expect(ids.length, StoreSearch.entries.length);
    });

    test('every entry has a label and an icon', () {
      for (final entry in StoreSearch.entries) {
        expect(entry.label, isNotEmpty, reason: entry.id);
        expect(entry.icon, isNotNull, reason: entry.id);
      }
    });

    test('byId finds each entry and rejects unknown ids', () {
      for (final entry in StoreSearch.entries) {
        expect(StoreSearch.byId(entry.id), same(entry));
      }
      expect(StoreSearch.byId('nope'), isNull);
    });

    test('every entry builds an absolute https url', () {
      for (final entry in StoreSearch.entries) {
        final uri = entry.build('Catan');
        expect(uri.hasScheme, isTrue, reason: entry.id);
        expect(uri.scheme, 'https', reason: entry.id);
        expect(uri.host, isNotEmpty, reason: entry.id);
      }
    });
  });
}
