import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/data/models/challenge.dart';
import 'package:boardpocket/data/models/challenge_translations.dart';

void main() {
  group('Challenge Model', () {
    const challenge = Challenge(
      id: 'logic_alphabet',
      category: 'logic',
      difficulty: 'easy',
      iconName: 'sort_by_alpha',
    );

    test('exposes the i18n keys derived from its identity', () {
      expect(challenge.titleKey, 'challenge_logic_alphabet_title');
      expect(challenge.descriptionKey, 'challenge_logic_alphabet_desc');
      expect(challenge.categoryKey, 'challenge_cat_logic');
      expect(challenge.difficultyKey, 'challenge_diff_easy');
    });

    test('round-trips through a map', () {
      expect(Challenge.fromMap(challenge.toMap()), isNotNull);
      final restored = Challenge.fromMap(challenge.toMap());
      expect(restored.id, challenge.id);
      expect(restored.category, challenge.category);
      expect(restored.difficulty, challenge.difficulty);
      expect(restored.iconName, challenge.iconName);
    });

    test('toMap writes every field', () {
      final map = challenge.toMap();
      expect(map['id'], 'logic_alphabet');
      expect(map['category'], 'logic');
      expect(map['difficulty'], 'easy');
      expect(map['icon_name'], 'sort_by_alpha');
    });
  });

  group('defaultChallenges', () {
    test('has at least 30 entries', () {
      expect(defaultChallenges.length, greaterThanOrEqualTo(30));
    });

    test('has unique ids', () {
      final ids = defaultChallenges.map((c) => c.id).toSet();
      expect(ids.length, defaultChallenges.length);
    });

    test('every category is one of the known keys', () {
      for (final c in defaultChallenges) {
        expect(
          challengeCategories,
          contains(c.category),
          reason: '${c.id} has unknown category ${c.category}',
        );
      }
    });

    test('every difficulty is one of the known keys', () {
      for (final c in defaultChallenges) {
        expect(
          challengeDifficulties,
          contains(c.difficulty),
          reason: '${c.id} has unknown difficulty ${c.difficulty}',
        );
      }
    });

    test('every id and icon name are non-empty', () {
      for (final c in defaultChallenges) {
        expect(c.id, isNotEmpty, reason: 'empty id');
        expect(c.iconName, isNotEmpty, reason: '${c.id} has no icon');
      }
    });

    test('covers every category', () {
      final used = defaultChallenges.map((c) => c.category).toSet();
      for (final category in challengeCategories) {
        expect(used, contains(category), reason: 'no challenge in $category');
      }
    });
  });

  group('translations', () {
    const locales = ['en', 'pt', 'es'];

    test('every locale table exists', () {
      for (final code in locales) {
        expect(challengeTranslations[code], isNotNull, reason: code);
      }
    });

    test('all locales define exactly the same keys', () {
      final en = challengeTranslations['en']!.keys.toSet();
      for (final code in ['pt', 'es']) {
        expect(
          challengeTranslations[code]!.keys.toSet(),
          en,
          reason: 'locale $code has a different set of keys',
        );
      }
    });

    test('every challenge has a title and description in every locale', () {
      for (final code in locales) {
        final table = challengeTranslations[code]!;
        for (final c in defaultChallenges) {
          expect(
            table[c.titleKey],
            isNotNull,
            reason: '$code is missing ${c.titleKey}',
          );
          expect(
            table[c.descriptionKey],
            isNotNull,
            reason: '$code is missing ${c.descriptionKey}',
          );
          expect(table[c.titleKey], isNot(isEmpty));
          expect(table[c.descriptionKey], isNot(isEmpty));
        }
      }
    });

    test('every category and difficulty is translated everywhere', () {
      for (final code in locales) {
        final table = challengeTranslations[code]!;
        for (final category in challengeCategories) {
          expect(table['challenge_cat_$category'], isNotNull, reason: code);
        }
        for (final difficulty in challengeDifficulties) {
          expect(
            table['challenge_diff_$difficulty'],
            isNotNull,
            reason: code,
          );
        }
      }
    });

    test('no translation is an empty string or an English leftover', () {
      for (final code in locales) {
        for (final entry in challengeTranslations[code]!.entries) {
          expect(entry.value.trim(), isNotEmpty, reason: '${code}:${entry.key}');
        }
      }
    });
  });

  group('AppLocalizations lookup', () {
    test('resolves a challenge title per locale', () {
      const c = Challenge(
        id: 'logic_alphabet',
        category: 'logic',
        difficulty: 'easy',
        iconName: 'sort_by_alpha',
      );

      expect(
        AppLocalizations(const Locale('en')).challengeTitle(c),
        'Alphabet Challenge',
      );
      expect(
        AppLocalizations(const Locale('pt')).challengeTitle(c),
        'Desafio do Alfabeto',
      );
      expect(
        AppLocalizations(const Locale('es')).challengeTitle(c),
        'Desafío del Alfabeto',
      );
    });

    test('resolves description, category and difficulty', () {
      const c = Challenge(
        id: 'logic_alphabet',
        category: 'logic',
        difficulty: 'easy',
        iconName: 'sort_by_alpha',
      );

      for (final code in ['en', 'pt', 'es']) {
        final l10n = AppLocalizations(Locale(code));
        expect(l10n.challengeDescription(c), isNotEmpty);
        expect(l10n.challengeCategory(c), isNotEmpty);
        expect(l10n.challengeDifficulty(c), isNotEmpty);
      }
    });

    test('falls back to English for an unknown locale', () {
      const c = Challenge(
        id: 'logic_alphabet',
        category: 'logic',
        difficulty: 'easy',
        iconName: 'sort_by_alpha',
      );
      final unknown = AppLocalizations(const Locale('xx'));

      expect(
        unknown.challengeTitle(c),
        AppLocalizations(const Locale('en')).challengeTitle(c),
      );
    });

    test('never leaks the missing-translation marker', () {
      for (final code in ['en', 'pt', 'es']) {
        final l10n = AppLocalizations(Locale(code));
        for (final c in defaultChallenges) {
          expect(
            l10n.challengeTitle(c),
            isNot(contains('Missing translation')),
          );
        }
      }
    });
  });
}
