import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

/// Every getter that maps to a key in the tables.
List<String Function(AppLocalizations)> allGetters() => [
  (l) => l.appName,
  (l) => l.settings,
  (l) => l.appearance,
  (l) => l.darkMode,
  (l) => l.language,
  (l) => l.englishUs,
  (l) => l.portuguese,
  (l) => l.spanish,
  (l) => l.dataBackup,
  (l) => l.exportImportDesc,
  (l) => l.exportJson,
  (l) => l.importJson,
  (l) => l.about,
  (l) => l.version,
  (l) => l.privacyPolicy,
  (l) => l.collection,
  (l) => l.wishlist,
  (l) => l.randomizer,
  (l) => l.nameDraw,
  (l) => l.fingerPicker,
  (l) => l.challenge,
  (l) => l.addGame,
  (l) => l.editGame,
  (l) => l.title,
  (l) => l.players,
  (l) => l.time,
  (l) => l.category,
  (l) => l.complexity,
  (l) => l.description,
  (l) => l.save,
  (l) => l.cancel,
  (l) => l.delete,
  (l) => l.confirmDelete,
  (l) => l.deleteGameConfirm,
  (l) => l.totalPlays,
  (l) => l.winRate,
  (l) => l.lastPlayed,
  (l) => l.never,
  (l) => l.boardGamesCollector,
  (l) => l.searchGames,
  (l) => l.noGamesFound,
  (l) => l.startCollection,
  (l) => l.backupExported,
  (l) => l.backupImported,
  (l) => l.errorExporting,
  (l) => l.errorImporting,
  (l) => l.importCancelled,
  (l) => l.selectLanguage,
  (l) => l.noGamesYet,
  (l) => l.tapToAddFirstGame,
  (l) => l.yourWishlistIsEmpty,
  (l) => l.addGamesYouWant,
  (l) => l.all,
  (l) => l.gameNight,
  (l) => l.chooseYourFate,
  (l) => l.whoStarts,
  (l) => l.fingerPickerDesc,
  (l) => l.nameDrawDesc,
  (l) => l.challengesDesc,
  (l) => l.randomlySelectPlayer,
  (l) => l.enterPlayerName,
  (l) => l.noPlayersYet,
  (l) => l.addPlayersToStart,
  (l) => l.drawing,
  (l) => l.drawWinner,
  (l) => l.theWinnerIs,
  (l) => l.drawAgain,
  (l) => l.gameMaster,
  (l) => l.firstPlayerDecider,
  (l) => l.shuffleChallenge,
  (l) => l.winnerTakesLead,
  (l) => l.newBoardGame,
  (l) => l.uploadCover,
  (l) => l.gameTitle,
  (l) => l.enterGameTitle,
  (l) => l.playTime,
  (l) => l.addToCollection,
  (l) => l.light,
  (l) => l.medium,
  (l) => l.heavy,
  (l) => l.expert,
  (l) => l.neverPlayed,
  (l) => l.addPlaySession,
  (l) => l.won,
  (l) => l.lost,
  (l) => l.daysAgo,
  (l) => l.weeksAgo,
  (l) => l.monthsAgo,
  (l) => l.today,
  (l) => l.yesterday,
  (l) => l.fingersCount,
  (l) => l.finger,
  (l) => l.fingers,
  (l) => l.tapToAddFingers,
  (l) => l.addMoreFingersOrStart,
  (l) => l.startSelection,
  (l) => l.clearAll,
  (l) => l.selecting,
  (l) => l.keepFingersPressed,
  (l) => l.fingerNumberWon,
  (l) => l.playAgain,
  (l) => l.addAtLeastTwoFingers,
  (l) => l.seconds,
  (l) => l.winnerSelected,
  (l) => l.randomGamePicker,
  (l) => l.pickRandomGame,
  (l) => l.pickAgain,
  (l) => l.noGamesToPick,
  (l) => l.addGamesToUsePicker,
  (l) => l.tapToPickGame,
  (l) => l.gameAvailable,
  (l) => l.gamesAvailable,
  (l) => l.tapCardToViewDetails,
  (l) => l.randomGamePickerDesc,
  (l) => l.ranking,
  (l) => l.statistics,
  (l) => l.gamesRanking,
  (l) => l.addGamesToSeeRanking,
  (l) => l.noGamesPlayedYet,
  (l) => l.winsVsLosses,
  (l) => l.wins,
  (l) => l.losses,
  (l) => l.noPlaysRecorded,
  (l) => l.mostPlayedGames,
  (l) => l.game,
  (l) => l.plays,
  (l) => l.winRateShort,
  (l) => l.diceRoller,
  (l) => l.diceRollerDesc,
  (l) => l.selectDice,
  (l) => l.selectDiceDesc,
  (l) => l.noDiceSelected,
  (l) => l.yourPool,
  (l) => l.rollResult,
  (l) => l.roll,
  (l) => l.rollDice,
  (l) => l.rolling,
  (l) => l.total,
  (l) => l.searchCovers,
  (l) => l.searchCoversHint,
  (l) => l.coverSearchNoResults,
  (l) => l.coverSearchNoResultsDesc,
  (l) => l.coverSearchError,
  (l) => l.coverSearchErrorDesc,
  (l) => l.coverSearchBusy,
  (l) => l.coverSearchBusyDesc,
  (l) => l.openSource,
  (l) => l.coverSearchRelaxed('dixit'),
];

const locales = ['en', 'pt', 'es'];

void main() {
  group('AppLocalizations', () {
    test('every locale resolves every key used by the UI', () {
      for (final code in locales) {
        final l10n = AppLocalizations(Locale(code));
        final missing = <String>[];

        for (final getter in allGetters()) {
          final value = getter(l10n);
          if (value.isEmpty || value.startsWith('Missing translation:')) {
            missing.add(value);
          }
        }

        expect(missing, isEmpty, reason: 'locale "$code" has untranslated keys');
      }
    });

    test('falls back to English for an unknown locale', () {
      final unknown = AppLocalizations(const Locale('xx'));
      final english = AppLocalizations(const Locale('en'));

      expect(unknown.collection, english.collection);
      expect(unknown.diceRoller, english.diceRoller);
    });

    test('getString reports the key when it does not exist', () {
      final l10n = AppLocalizations(const Locale('en'));
      expect(l10n.getString('does_not_exist'), 'Missing translation: does_not_exist');
    });

    test('translations actually differ between locales', () {
      final en = AppLocalizations(const Locale('en'));
      final pt = AppLocalizations(const Locale('pt'));
      final es = AppLocalizations(const Locale('es'));

      expect(en.collection, 'Collection');
      expect(pt.collection, 'Coleção');
      expect(es.collection, 'Colección');
    });

    test('coverSearchRelaxed substitutes the query', () {
      final pt = AppLocalizations(const Locale('pt'));
      final message = pt.coverSearchRelaxed('dixit');

      expect(message, contains('dixit'));
      expect(message, isNot(contains('{query}')));
    });

    test('getLanguageDisplayName maps codes to their names', () {
      final pt = AppLocalizations(const Locale('pt'));

      expect(pt.getLanguageDisplayName('en'), pt.englishUs);
      expect(pt.getLanguageDisplayName('pt'), pt.portuguese);
      expect(pt.getLanguageDisplayName('es'), pt.spanish);
      expect(pt.getLanguageDisplayName('zz'), pt.englishUs);
    });

    test('app name is not translated', () {
      for (final code in locales) {
        expect(AppLocalizations(Locale(code)).appName, 'BoardPocket');
      }
    });

    group('delegate', () {
      test('supports the three locales', () {
        for (final code in locales) {
          expect(
            AppLocalizations.delegate.isSupported(Locale(code)),
            isTrue,
            reason: code,
          );
        }
      });

      test('rejects unknown locales', () {
        expect(AppLocalizations.delegate.isSupported(const Locale('xx')), isFalse);
      });

      test('loads a localization for the given locale', () async {
        final loaded = await AppLocalizations.delegate.load(const Locale('pt'));
        expect(loaded, isA<AppLocalizations>());
        expect(loaded.locale.languageCode, 'pt');
      });

      test('does not require a reload', () {
        const delegate = AppLocalizations.delegate;
        expect(delegate.shouldReload(delegate), isFalse);
      });
    });
  });
}
