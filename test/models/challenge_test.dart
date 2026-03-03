import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/challenge.dart';

void main() {
  group('Challenge Model', () {
    late Challenge challenge;

    setUp(() {
      challenge = Challenge(
        id: '1',
        title: 'Test Challenge',
        description: 'Test Description',
        category: 'Test Category',
        iconName: 'test_icon',
      );
    });

    test('should create Challenge with all properties', () {
      expect(challenge.id, '1');
      expect(challenge.title, 'Test Challenge');
      expect(challenge.description, 'Test Description');
      expect(challenge.category, 'Test Category');
      expect(challenge.iconName, 'test_icon');
    });

    test('should convert Challenge to Map', () {
      final map = challenge.toMap();

      expect(map['id'], '1');
      expect(map['title'], 'Test Challenge');
      expect(map['description'], 'Test Description');
      expect(map['category'], 'Test Category');
      expect(map['icon_name'], 'test_icon');
    });

    test('should create Challenge from Map', () {
      final map = {
        'id': '2',
        'title': 'Foodie Challenge',
        'description':
            'Whoever ate cheese pizza most recently gets to go first!',
        'category': 'Foodie Challenge',
        'icon_name': 'restaurant',
      };

      final challengeFromMap = Challenge.fromMap(map);

      expect(challengeFromMap.id, '2');
      expect(challengeFromMap.title, 'Foodie Challenge');
      expect(
        challengeFromMap.description,
        'Whoever ate cheese pizza most recently gets to go first!',
      );
      expect(challengeFromMap.category, 'Foodie Challenge');
      expect(challengeFromMap.iconName, 'restaurant');
    });

    group('defaultChallenges', () {
      test('should have 8 predefined challenges', () {
        expect(defaultChallenges.length, 8);
      });

      test('should have valid ids', () {
        for (final c in defaultChallenges) {
          expect(c.id, isNotEmpty);
        }
      });

      test('should have valid titles', () {
        for (final c in defaultChallenges) {
          expect(c.title, isNotEmpty);
        }
      });

      test('should have valid descriptions', () {
        for (final c in defaultChallenges) {
          expect(c.description, isNotEmpty);
        }
      });

      test('should have valid categories', () {
        for (final c in defaultChallenges) {
          expect(c.category, isNotEmpty);
        }
      });

      test('should have valid icon names', () {
        for (final c in defaultChallenges) {
          expect(c.iconName, isNotEmpty);
        }
      });

      test('should include Foodie Challenge', () {
        final foodieChallenge = defaultChallenges.firstWhere(
          (c) => c.id == '1',
        );
        expect(foodieChallenge.title, 'Foodie Challenge');
        expect(foodieChallenge.iconName, 'restaurant');
      });

      test('should include Birthday Challenge', () {
        final birthdayChallenge = defaultChallenges.firstWhere(
          (c) => c.id == '2',
        );
        expect(birthdayChallenge.title, 'Birthday Challenge');
        expect(birthdayChallenge.iconName, 'cake');
      });

      test('should include Travel Challenge', () {
        final travelChallenge = defaultChallenges.firstWhere(
          (c) => c.id == '3',
        );
        expect(travelChallenge.title, 'Travel Challenge');
        expect(travelChallenge.iconName, 'flight');
      });

      test('should include Phone Challenge', () {
        final phoneChallenge = defaultChallenges.firstWhere((c) => c.id == '4');
        expect(phoneChallenge.title, 'Phone Challenge');
        expect(phoneChallenge.iconName, 'battery_alert');
      });

      test('should include Height Challenge', () {
        final heightChallenge = defaultChallenges.firstWhere(
          (c) => c.id == '5',
        );
        expect(heightChallenge.title, 'Height Challenge');
        expect(heightChallenge.iconName, 'height');
      });

      test('should include Alphabet Challenge', () {
        final alphabetChallenge = defaultChallenges.firstWhere(
          (c) => c.id == '6',
        );
        expect(alphabetChallenge.title, 'Alphabet Challenge');
        expect(alphabetChallenge.iconName, 'sort_by_alpha');
      });

      test('should include Pet Challenge', () {
        final petChallenge = defaultChallenges.firstWhere((c) => c.id == '7');
        expect(petChallenge.title, 'Pet Challenge');
        expect(petChallenge.iconName, 'pets');
      });

      test('should include Shoe Challenge', () {
        final shoeChallenge = defaultChallenges.firstWhere((c) => c.id == '8');
        expect(shoeChallenge.title, 'Shoe Challenge');
        expect(shoeChallenge.iconName, 'checkroom');
      });
    });
  });
}
