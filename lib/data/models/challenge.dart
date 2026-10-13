/// A "who goes first" mini-game shown on the Challenge screen.
///
/// Only the identity lives on the model. The title and description are looked
/// up per locale through [AppLocalizations], keyed off [id], so every challenge
/// is translated into English, Portuguese and Spanish.
class Challenge {
  /// Stable identifier, also the i18n key suffix:
  /// `challenge_<id>_title` and `challenge_<id>_desc`.
  final String id;

  /// i18n category key suffix: `challenge_cat_<category>`.
  final String category;

  /// i18n difficulty key suffix: `challenge_diff_<difficulty>`.
  final String difficulty;

  final String iconName;

  const Challenge({
    required this.id,
    required this.category,
    required this.difficulty,
    required this.iconName,
  });

  String get titleKey => 'challenge_${id}_title';
  String get descriptionKey => 'challenge_${id}_desc';
  String get categoryKey => 'challenge_cat_$category';
  String get difficultyKey => 'challenge_diff_$difficulty';

  Map<String, dynamic> toMap() => {
    'id': id,
    'category': category,
    'difficulty': difficulty,
    'icon_name': iconName,
  };

  factory Challenge.fromMap(Map<String, dynamic> map) => Challenge(
    id: map['id'] as String,
    category: map['category'] as String,
    difficulty: map['difficulty'] as String,
    iconName: map['icon_name'] as String,
  );
}

/// Category keys. Each one is translated.
const List<String> challengeCategories = [
  'dare',
  'life',
  'logic',
  'physical',
  'food',
  'luck',
  'creative',
  'tech',
];

/// Difficulty keys, from easiest to hardest.
const List<String> challengeDifficulties = ['easy', 'medium', 'hard'];

const List<Challenge> defaultChallenges = [
  // --- dare ----------------------------------------------------------------
  Challenge(
    id: 'dare_cheese_pizza',
    category: 'food',
    difficulty: 'easy',
    iconName: 'restaurant',
  ),
  Challenge(
    id: 'dare_truth_or_dare',
    category: 'dare',
    difficulty: 'medium',
    iconName: 'casino',
  ),
  Challenge(
    id: 'dare_sing_next_song',
    category: 'dare',
    difficulty: 'hard',
    iconName: 'music_note',
  ),
  Challenge(
    id: 'dare_impressions',
    category: 'dare',
    difficulty: 'medium',
    iconName: 'theater_comedy',
  ),
  Challenge(
    id: 'dare_no_smiling',
    category: 'dare',
    difficulty: 'medium',
    iconName: 'sentiment_neutral',
  ),

  // --- life ----------------------------------------------------------------
  Challenge(
    id: 'life_birthday',
    category: 'life',
    difficulty: 'easy',
    iconName: 'cake',
  ),
  Challenge(
    id: 'life_travel',
    category: 'life',
    difficulty: 'easy',
    iconName: 'flight',
  ),
  Challenge(
    id: 'life_battery',
    category: 'tech',
    difficulty: 'easy',
    iconName: 'battery_alert',
  ),
  Challenge(
    id: 'life_pets',
    category: 'life',
    difficulty: 'easy',
    iconName: 'pets',
  ),
  Challenge(
    id: 'life_shoes',
    category: 'life',
    difficulty: 'easy',
    iconName: 'checkroom',
  ),
  Challenge(
    id: 'life_early_bird',
    category: 'life',
    difficulty: 'easy',
    iconName: 'wb_sunny',
  ),
  Challenge(
    id: 'life_coffee',
    category: 'food',
    difficulty: 'easy',
    iconName: 'local_cafe',
  ),
  Challenge(
    id: 'life_left_handed',
    category: 'life',
    difficulty: 'easy',
    iconName: 'pan_tool',
  ),
  Challenge(
    id: 'life_last_vacation',
    category: 'life',
    difficulty: 'medium',
    iconName: 'beach_access',
  ),

  // --- logic ---------------------------------------------------------------
  Challenge(
    id: 'logic_alphabet',
    category: 'logic',
    difficulty: 'easy',
    iconName: 'sort_by_alpha',
  ),
  Challenge(
    id: 'logic_height',
    category: 'physical',
    difficulty: 'easy',
    iconName: 'height',
  ),
  Challenge(
    id: 'logic_longest_name',
    category: 'logic',
    difficulty: 'easy',
    iconName: 'abc',
  ),
  Challenge(
    id: 'logic_last_game_played',
    category: 'logic',
    difficulty: 'medium',
    iconName: 'history',
  ),
  Challenge(
    id: 'logic_most_tokens',
    category: 'logic',
    difficulty: 'medium',
    iconName: 'toll',
  ),
  Challenge(
    id: 'logic_left_hand',
    category: 'logic',
    difficulty: 'hard',
    iconName: 'psychology',
  ),

  // --- luck ----------------------------------------------------------------
  Challenge(
    id: 'luck_flip_coin',
    category: 'luck',
    difficulty: 'easy',
    iconName: 'currency_bitcoin',
  ),
  Challenge(
    id: 'luck_draw_dice',
    category: 'luck',
    difficulty: 'easy',
    iconName: 'casino',
  ),
  Challenge(
    id: 'luck_odd_one_out',
    category: 'luck',
    difficulty: 'medium',
    iconName: 'help_outline',
  ),
  Challenge(
    id: 'luck_closed_eyes',
    category: 'luck',
    difficulty: 'medium',
    iconName: 'visibility_off',
  ),
  Challenge(
    id: 'luck_brain_wave',
    category: 'luck',
    difficulty: 'medium',
    iconName: 'waves',
  ),

  // --- creative ------------------------------------------------------------
  Challenge(
    id: 'creative_draw_something',
    category: 'creative',
    difficulty: 'medium',
    iconName: 'brush',
  ),
  Challenge(
    id: 'creative_invent_a_game',
    category: 'creative',
    difficulty: 'hard',
    iconName: 'lightbulb',
  ),
  Challenge(
    id: 'creative_tell_a_story',
    category: 'creative',
    difficulty: 'medium',
    iconName: 'auto_stories',
  ),
  Challenge(
    id: 'creative_pick_a_remix',
    category: 'creative',
    difficulty: 'easy',
    iconName: 'shuffle',
  ),

  // --- late additions -----------------------------------------------------
  Challenge(
    id: 'logic_most_wins',
    category: 'logic',
    difficulty: 'medium',
    iconName: 'emoji_events',
  ),
  Challenge(
    id: 'luck_card_stack',
    category: 'luck',
    difficulty: 'medium',
    iconName: 'style',
  ),
  Challenge(
    id: 'dare_last_game_story',
    category: 'dare',
    difficulty: 'medium',
    iconName: 'forum',
  ),
  Challenge(
    id: 'creative_describe_sound',
    category: 'creative',
    difficulty: 'hard',
    iconName: 'graphic_eq',
  ),

  // --- extra set: 34-50 ---------------------------------------------------
  Challenge(
    id: 'dare_double_dare',
    category: 'dare',
    difficulty: 'medium',
    iconName: 'double_arrow',
  ),
  Challenge(
    id: 'dare_charades',
    category: 'dare',
    difficulty: 'easy',
    iconName: 'emoji_emotions',
  ),
  Challenge(
    id: 'life_favorite_food',
    category: 'food',
    difficulty: 'easy',
    iconName: 'restaurant',
  ),
  Challenge(
    id: 'life_longest_drive',
    category: 'life',
    difficulty: 'easy',
    iconName: 'directions_car',
  ),
  Challenge(
    id: 'life_best_story',
    category: 'life',
    difficulty: 'medium',
    iconName: 'auto_stories',
  ),
  Challenge(
    id: 'logic_finger_count',
    category: 'logic',
    difficulty: 'easy',
    iconName: 'back_hand',
  ),
  Challenge(
    id: 'logic_name_letter',
    category: 'logic',
    difficulty: 'medium',
    iconName: 'abc',
  ),
  Challenge(
    id: 'logic_most_expensive',
    category: 'logic',
    difficulty: 'medium',
    iconName: 'shopping_bag',
  ),
  Challenge(
    id: 'logic_fastest_answer',
    category: 'logic',
    difficulty: 'medium',
    iconName: 'bolt',
  ),
  Challenge(
    id: 'luck_dice_sum',
    category: 'luck',
    difficulty: 'easy',
    iconName: 'casino',
  ),
  Challenge(
    id: 'luck_in_my_hand',
    category: 'luck',
    difficulty: 'medium',
    iconName: 'back_hand',
  ),
  Challenge(
    id: 'luck_roulette',
    category: 'luck',
    difficulty: 'hard',
    iconName: 'smart_toy',
  ),
  Challenge(
    id: 'creative_draw_face',
    category: 'creative',
    difficulty: 'medium',
    iconName: 'photo_camera',
  ),
  Challenge(
    id: 'creative_game_name',
    category: 'creative',
    difficulty: 'easy',
    iconName: 'volunteer_activism',
  ),
  Challenge(
    id: 'creative_sound_effect',
    category: 'creative',
    difficulty: 'medium',
    iconName: 'campaign',
  ),
  Challenge(
    id: 'physical_warmest_hands',
    category: 'physical',
    difficulty: 'easy',
    iconName: 'whatshot',
  ),
  Challenge(
    id: 'physical_fastest_reaction',
    category: 'physical',
    difficulty: 'medium',
    iconName: 'timer',
  ),
];
