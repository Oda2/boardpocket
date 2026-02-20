import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class PlayerProvider extends ChangeNotifier {
  final PlayerRepository _repository = PlayerRepository();

  List<Player> _players = [];
  String? _winner;
  bool _isDrawing = false;

  List<Player> get players => _players;
  String? get winner => _winner;
  bool get isDrawing => _isDrawing;

  Future<void> loadPlayers() async {
    _players = await _repository.getAll();
    notifyListeners();
  }

  Future<void> addPlayer(String name) async {
    final player = Player(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    await _repository.create(player);
    await loadPlayers();
  }

  Future<void> deletePlayer(String id) async {
    await _repository.delete(id);
    await loadPlayers();
  }

  void drawWinner() {
    if (_players.isEmpty) return;

    _isDrawing = true;
    notifyListeners();

    // Simulate drawing animation
    Future.delayed(const Duration(seconds: 1), () {
      _winner = _players[DateTime.now().millisecond % _players.length].name;
      _isDrawing = false;
      notifyListeners();
    });
  }

  void clearWinner() {
    _winner = null;
    notifyListeners();
  }
}
