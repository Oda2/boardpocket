import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/data/services/cover_search_service.dart';
import 'package:boardpocket/presentation/screens/cover_search_screen.dart';

/// Records the queries the screen sends and answers with a fixed result.
class _SpyClient extends http.BaseClient {
  _SpyClient(this.payload);

  final Map<String, dynamic> payload;
  final List<String> queries = [];

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final uri = request.url;
    queries.add(uri.queryParameters['q'] ?? uri.queryParameters['gsrsearch'] ?? '');
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(payload))),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}

/// Fails every request, to exercise the error paths.
class _DeadClient extends http.BaseClient {
  _DeadClient([this.statusCode]);

  final int? statusCode;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (statusCode != null) {
      return http.StreamedResponse(
        Stream.value(utf8.encode('nope')),
        statusCode!,
      );
    }
    throw Exception('network down');
  }
}

const _withResults = {
  'results': [
    {
      'url': 'https://images.example/a.jpg',
      'thumbnail': 'https://images.example/a_thumb.jpg',
      'title': 'Alpha cover',
    },
    {
      'url': 'https://images.example/b.jpg',
      'thumbnail': 'https://images.example/b_thumb.jpg',
      'title': 'Beta cover',
    },
  ],
};

const _empty = {'results': []};

Widget buildApp({
  required CoverSearchService service,
  String? initialQuery,
  void Function(String? result)? onPop,
}) {
  final router = GoRouter(
    initialLocation: '/search',
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('root')),
      ),
      GoRoute(
        path: '/search',
        builder: (_, _) => CoverSearchScreen(
          initialQuery: initialQuery,
          service: service,
        ),
      ),
    ],
  );

  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
  );
}

void main() {
  group('CoverSearchScreen', () {
    testWidgets('shows the search bar and header', (tester) async {
      await tester.pumpWidget(
        buildApp(service: CoverSearchService(client: _SpyClient(_empty))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Covers'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('starts with a prompt when there is no query', (tester) async {
      await tester.pumpWidget(
        buildApp(service: CoverSearchService(client: _SpyClient(_empty))),
      );
      await tester.pumpAndSettle();

      expect(find.text('Search Covers'), findsWidgets);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('searches immediately for the initial query', (tester) async {
      final client = _SpyClient(_withResults);
      await tester.pumpWidget(
        buildApp(
          service: CoverSearchService(client: client),
          initialQuery: 'catan',
        ),
      );
      await tester.pumpAndSettle();

      expect(client.queries, isNotEmpty);
      expect(client.queries.first, 'catan');
    });

    testWidgets('renders one tile per result', (tester) async {
      await tester.pumpWidget(
        buildApp(
          service: CoverSearchService(client: _SpyClient(_withResults)),
          initialQuery: 'catan',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Alpha cover'), findsOneWidget);
      expect(find.text('Beta cover'), findsOneWidget);
      expect(find.text('Openverse'), findsNWidgets(2));
    });

    testWidgets('typing triggers a debounced search', (tester) async {
      final client = _SpyClient(_withResults);
      await tester.pumpWidget(
        buildApp(service: CoverSearchService(client: client)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'ticket to ride');
      await tester.pump(const Duration(milliseconds: 300));
      // Still inside the debounce window.
      expect(client.queries, isEmpty);

      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(client.queries, isNotEmpty);
      expect(client.queries.last, 'ticket to ride');
    });

    testWidgets('clearing the field hides the results', (tester) async {
      await tester.pumpWidget(
        buildApp(
          service: CoverSearchService(client: _SpyClient(_withResults)),
          initialQuery: 'catan',
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alpha cover'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '');
      await tester.pumpAndSettle();

      expect(find.text('Alpha cover'), findsNothing);
    });

    testWidgets('shows "no results" for an empty answer', (tester) async {
      await tester.pumpWidget(
        buildApp(
          service: CoverSearchService(client: _SpyClient(_empty)),
          initialQuery: 'zzzz',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No images found'), findsOneWidget);
      expect(find.textContaining('no photo for this game'), findsOneWidget);
    });

    testWidgets('shows an offline message when the network is down', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildApp(
          service: CoverSearchService(client: _DeadClient()),
          initialQuery: 'catan',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Could not reach the image search'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('shows a rate-limit message on HTTP 429', (tester) async {
      await tester.pumpWidget(
        buildApp(
          service: CoverSearchService(client: _DeadClient(429)),
          initialQuery: 'catan',
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Too many searches'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_top), findsOneWidget);
    });

    testWidgets('a blank query is not sent', (tester) async {
      final client = _SpyClient(_withResults);
      await tester.pumpWidget(
        buildApp(service: CoverSearchService(client: client), initialQuery: '   '),
      );
      await tester.pumpAndSettle();

      expect(client.queries, isEmpty);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow on a small phone', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        buildApp(
          service: CoverSearchService(client: _SpyClient(_withResults)),
          initialQuery: 'catan',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('renders many results without overflow', (tester) async {
      final many = {
        'results': [
          for (var i = 0; i < 30; i++)
            {
              'url': 'https://images.example/$i.jpg',
              'thumbnail': 'https://images.example/${i}_t.jpg',
              'title': 'Cover number $i',
            },
        ],
      };

      await tester.pumpWidget(
        buildApp(
          service: CoverSearchService(client: _SpyClient(many)),
          initialQuery: 'catan',
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
