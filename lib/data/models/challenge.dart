class Challenge {
  final String id;
  final String title;
  final String description;
  final String category;
  final String iconName;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.iconName,
  });

  factory Challenge.fromMap(Map<String, dynamic> map) {
    return Challenge(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      category: map['category'] as String,
      iconName: map['icon_name'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon_name': iconName,
    };
  }
}

// Predefined challenges
final List<Challenge> defaultChallenges = [
  Challenge(
    id: '1',
    title: 'Foodie Challenge',
    description: 'Whoever ate cheese pizza most recently gets to go first!',
    category: 'Foodie Challenge',
    iconName: 'restaurant',
  ),
  Challenge(
    id: '2',
    title: 'Birthday Challenge',
    description: 'The player whose birthday is closest to today goes first!',
    category: 'Life Challenge',
    iconName: 'cake',
  ),
  Challenge(
    id: '3',
    title: 'Travel Challenge',
    description: 'Whoever traveled the farthest to get here goes first!',
    category: 'Travel Challenge',
    iconName: 'flight',
  ),
  Challenge(
    id: '4',
    title: 'Phone Challenge',
    description: 'Whoever has the lowest battery percentage goes first!',
    category: 'Tech Challenge',
    iconName: 'battery_alert',
  ),
  Challenge(
    id: '5',
    title: 'Height Challenge',
    description: 'The tallest player gets to go first!',
    category: 'Physical Challenge',
    iconName: 'height',
  ),
  Challenge(
    id: '6',
    title: 'Alphabet Challenge',
    description: 'The player whose name comes first alphabetically goes first!',
    category: 'Logic Challenge',
    iconName: 'sort_by_alpha',
  ),
  Challenge(
    id: '7',
    title: 'Pet Challenge',
    description: 'Whoever has the most pets goes first!',
    category: 'Life Challenge',
    iconName: 'pets',
  ),
  Challenge(
    id: '8',
    title: 'Shoe Challenge',
    description: 'Whoever is wearing the biggest shoe size goes first!',
    category: 'Physical Challenge',
    iconName: 'checkroom',
  ),
];
