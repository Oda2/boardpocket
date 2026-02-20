class Game {
  final String id;
  final String title;
  final String? imagePath;
  final String players;
  final String time;
  final String category;
  final int? minPlayers;
  final int? maxPlayers;
  final int? playTime;
  final double? complexity;
  final int totalPlays;
  final int wins;
  final int losses;
  final double winRate;
  final DateTime? lastPlayed;
  final DateTime createdAt;
  final DateTime updatedAt;

  Game({
    required this.id,
    required this.title,
    this.imagePath,
    required this.players,
    required this.time,
    required this.category,
    this.minPlayers,
    this.maxPlayers,
    this.playTime,
    this.complexity,
    this.totalPlays = 0,
    this.wins = 0,
    this.losses = 0,
    this.winRate = 0.0,
    this.lastPlayed,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'image_path': imagePath,
      'players': players,
      'time': time,
      'category': category,
      'min_players': minPlayers,
      'max_players': maxPlayers,
      'play_time': playTime,
      'complexity': complexity,
      'total_plays': totalPlays,
      'wins': wins,
      'losses': losses,
      'win_rate': winRate,
      'last_played': lastPlayed?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Game.fromMap(Map<String, dynamic> map) {
    return Game(
      id: map['id'] as String,
      title: map['title'] as String,
      imagePath: map['image_path'] as String?,
      players: map['players'] as String,
      time: map['time'] as String,
      category: map['category'] as String,
      minPlayers: map['min_players'] as int?,
      maxPlayers: map['max_players'] as int?,
      playTime: map['play_time'] as int?,
      complexity: map['complexity'] as double?,
      totalPlays: map['total_plays'] as int? ?? 0,
      wins: map['wins'] as int? ?? 0,
      losses: map['losses'] as int? ?? 0,
      winRate: map['win_rate'] as double? ?? 0.0,
      lastPlayed: map['last_played'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['last_played'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
    );
  }

  Game copyWith({
    String? id,
    String? title,
    String? imagePath,
    String? players,
    String? time,
    String? category,
    int? minPlayers,
    int? maxPlayers,
    int? playTime,
    double? complexity,
    int? totalPlays,
    int? wins,
    int? losses,
    double? winRate,
    DateTime? lastPlayed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Game(
      id: id ?? this.id,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      players: players ?? this.players,
      time: time ?? this.time,
      category: category ?? this.category,
      minPlayers: minPlayers ?? this.minPlayers,
      maxPlayers: maxPlayers ?? this.maxPlayers,
      playTime: playTime ?? this.playTime,
      complexity: complexity ?? this.complexity,
      totalPlays: totalPlays ?? this.totalPlays,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      winRate: winRate ?? this.winRate,
      lastPlayed: lastPlayed ?? this.lastPlayed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Calculate win rate based on wins and losses
  double calculateWinRate() {
    final total = wins + losses;
    if (total == 0) return 0.0;
    return (wins / total) * 100;
  }

  // Record a win
  Game recordWin() {
    final newWins = wins + 1;
    final newTotalPlays = totalPlays + 1;
    final newWinRate = calculateWinRateWith(newWins, losses);
    return copyWith(
      wins: newWins,
      totalPlays: newTotalPlays,
      winRate: newWinRate,
      lastPlayed: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Record a loss
  Game recordLoss() {
    final newLosses = losses + 1;
    final newTotalPlays = totalPlays + 1;
    final newWinRate = calculateWinRateWith(wins, newLosses);
    return copyWith(
      losses: newLosses,
      totalPlays: newTotalPlays,
      winRate: newWinRate,
      lastPlayed: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  // Record just a play (for backward compatibility)
  Game recordPlay() {
    return copyWith(
      totalPlays: totalPlays + 1,
      lastPlayed: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  double calculateWinRateWith(int wins, int losses) {
    final total = wins + losses;
    if (total == 0) return 0.0;
    return (wins / total) * 100;
  }
}
