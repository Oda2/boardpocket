import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/challenge.dart';
import 'package:boardpocket/presentation/providers/challenge_provider.dart';

void main() {
  group('ChallengeProvider', () {
    late ChallengeProvider challengeProvider;

    setUp(() {
      challengeProvider = ChallengeProvider();
    });

    test('should have default challenges', () {
      expect(challengeProvider.challenges, defaultChallenges);
    });

    test('should have 8 default challenges', () {
      expect(challengeProvider.challenges.length, 8);
    });

    test('should have null current challenge initially', () {
      expect(challengeProvider.currentChallenge, isNull);
    });

    test('should shuffle challenge', () {
      challengeProvider.shuffleChallenge();
      expect(challengeProvider.currentChallenge, isNotNull);
    });

    test('should notify listeners when shuffling challenge', () {
      bool notified = false;
      challengeProvider.addListener(() {
        notified = true;
      });

      challengeProvider.shuffleChallenge();

      expect(notified, true);
    });

    test('should set challenge', () {
      final challenge = defaultChallenges.first;
      challengeProvider.setChallenge(challenge);
      expect(challengeProvider.currentChallenge, challenge);
    });

    test('should notify listeners when setting challenge', () {
      bool notified = false;
      challengeProvider.addListener(() {
        notified = true;
      });

      challengeProvider.setChallenge(defaultChallenges.first);

      expect(notified, true);
    });

    test('should return a challenge from the list when shuffling', () {
      challengeProvider.shuffleChallenge();
      final current = challengeProvider.currentChallenge;
      expect(defaultChallenges.contains(current), true);
    });
  });
}
