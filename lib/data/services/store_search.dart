import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A storefront the user can search for a title in.
class StoreSearchEntry {
  final String id;
  final String label;
  final IconData icon;
  final Uri Function(String title) build;

  const StoreSearchEntry({
    required this.id,
    required this.label,
    required this.icon,
    required this.build,
  });
}

/// Builds "search this title here" links for the storefronts people actually
/// buy board games from.
///
/// These are plain web links, not APIs: nothing is fetched automatically, no
/// key or token is involved, and the app only opens the browser. That keeps the
/// app local-first and keeps it working even if a store changes its API.
///
/// Prices still have to be typed in by hand, because none of these expose a
/// free, key-less product search (Google retired the Shopping API and
/// Mercado Livre now answers 403 without OAuth credentials).
class StoreSearch {
  const StoreSearch._();

  /// Google web search, with "board game" appended to keep results on topic.
  static Uri google(String title) => Uri.https('www.google.com', '/search', {
    'q': '${title.trim()} board game',
  });

  /// Amazon Brazil, or the US storefront when [brazil] is false.
  static Uri amazon(String title, {bool brazil = true}) => Uri.https(
    brazil ? 'www.amazon.com.br' : 'www.amazon.com',
    '/s',
    {'k': title.trim()},
  );

  /// Mercado Livre Brazilian marketplace.
  static Uri mercadoLivre(String title) =>
      Uri.https('lista.mercadolivre.com.br', '/', {'q': title.trim()});

  /// BoardGameGeek's search page.
  ///
  /// This is the website, not the XML API: the API is paid, but the page is
  /// free to open and is the best catalog for player counts and descriptions.
  static Uri boardGameGeek(String title) => Uri.https(
    'boardgamegeek.com',
    '/geeksearch.php',
    {'action': 'search', 'objecttype': 'boardgame', 'q': title.trim()},
  );

  /// BoardGameArena search page.
  ///
  /// Same reasoning as BoardGameGeek: a plain website link, no API involved,
  /// and BGA is the best place to actually play online.
  static Uri boardGameArena(String title) => Uri.https(
    'boardgamearena.net',
    '/game/list',
    {'search': title.trim()},
  );

  /// The stores offered in the UI.
  static const List<StoreSearchEntry> entries = [
    StoreSearchEntry(
      id: 'google',
      label: 'Google',
      icon: Icons.search,
      build: google,
    ),
    StoreSearchEntry(
      id: 'amazon',
      label: 'Amazon',
      icon: Icons.shopping_cart,
      build: amazon,
    ),
    StoreSearchEntry(
      id: 'mercadolivre',
      label: 'Mercado Livre',
      icon: Icons.storefront,
      build: mercadoLivre,
    ),
    StoreSearchEntry(
      id: 'bgg',
      label: 'BoardGameGeek',
      icon: Icons.grid_view,
      build: boardGameGeek,
    ),
    StoreSearchEntry(
      id: 'bga',
      label: 'BoardGameArena',
      icon: Icons.public,
      build: boardGameArena,
    ),
  ];

  static StoreSearchEntry? byId(String id) {
    for (final entry in entries) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  /// Opens the store's search page for [title] in the browser.
  static Future<bool> open(StoreSearchEntry entry, String title) async {
    if (title.trim().isEmpty) return false;
    return launchUrl(
      entry.build(title),
      mode: LaunchMode.externalApplication,
    );
  }
}
