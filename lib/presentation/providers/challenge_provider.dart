import 'package:flutter/material.dart';
import '../../data/models/models.dart';

class ChallengeProvider extends ChangeNotifier {
  List<Challenge> _challenges = defaultChallenges;
  Challenge? _currentChallenge;

  List<Challenge> get challenges => _challenges;
  Challenge? get currentChallenge => _currentChallenge;

  void shuffleChallenge() {
    if (_challenges.isNotEmpty) {
      _currentChallenge =
          _challenges[DateTime.now().millisecond % _challenges.length];
      notifyListeners();
    }
  }

  void setChallenge(Challenge challenge) {
    _currentChallenge = challenge;
    notifyListeners();
  }
}
