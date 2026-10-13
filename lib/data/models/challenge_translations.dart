import 'package:boardpocket/data/models/challenge.dart';

/// Translations for the built-in challenges.
///
/// Every entry must exist for en, pt and es. [challengeTranslations] plus a
/// test keep that honest.
const Map<String, Map<String, String>> challengeTranslations = {
  'en': {
    // categories
    'challenge_cat_dare': 'Dare',
    'challenge_cat_life': 'Life',
    'challenge_cat_logic': 'Logic',
    'challenge_cat_physical': 'Physical',
    'challenge_cat_food': 'Food',
    'challenge_cat_luck': 'Luck',
    'challenge_cat_creative': 'Creative',
    'challenge_cat_tech': 'Tech',
    // difficulty
    'challenge_diff_easy': 'Easy',
    'challenge_diff_medium': 'Medium',
    'challenge_diff_hard': 'Hard',

    'challenge_dare_cheese_pizza_title': 'Pizza Challenge',
    'challenge_dare_cheese_pizza_desc':
        'Whoever ate cheese pizza most recently goes first!',

    'challenge_dare_truth_or_dare_title': 'Truth or Dare',
    'challenge_dare_truth_or_dare_desc':
        'Everyone answers "truth" or "dare" at random. Draw one from the hat to see which wins the round.',

    'challenge_dare_sing_next_song_title': 'Sing Along',
    'challenge_dare_sing_next_song_desc':
        'Whoever heard the last song playing goes first, and has to hum it.',

    'challenge_dare_impressions_title': 'Impressions',
    'challenge_dare_impressions_desc':
        'Each player acts out the name of a game. Whoever gets the most guesses right goes first.',

    'challenge_dare_no_smiling_title': 'No Smiling',
    'challenge_dare_no_smiling_desc':
        'The player who smiles first during this challenge loses and goes last.',

    'challenge_life_birthday_title': 'Birthday Challenge',
    'challenge_life_birthday_desc':
        'The player whose birthday is closest to today goes first!',

    'challenge_life_travel_title': 'Travel Challenge',
    'challenge_life_travel_desc':
        'Whoever travelled the farthest to get here goes first!',

    'challenge_life_battery_title': 'Phone Challenge',
    'challenge_life_battery_desc':
        'Whoever has the lowest battery percentage goes first!',

    'challenge_life_pets_title': 'Pet Challenge',
    'challenge_life_pets_desc': 'Whoever has the most pets goes first!',

    'challenge_life_shoes_title': 'Shoe Challenge',
    'challenge_life_shoes_desc':
        'Whoever is wearing the biggest shoe size goes first!',

    'challenge_life_early_bird_title': 'Early Bird',
    'challenge_life_early_bird_desc':
        'Whoever woke up earliest today goes first!',

    'challenge_life_coffee_title': 'Caffeine Level',
    'challenge_life_coffee_desc':
        'Whoever has had the most coffee today goes first!',

    'challenge_life_left_handed_title': 'Left or Right',
    'challenge_life_left_handed_desc':
        'Whoever is left-handed goes first. Tie means the person to their right goes first.',

    'challenge_life_last_vacation_title': 'Last Vacation',
    'challenge_life_last_vacation_desc':
        'Whoever took their most recent trip furthest from home goes first!',

    'challenge_logic_alphabet_title': 'Alphabet Challenge',
    'challenge_logic_alphabet_desc':
        'The player whose name comes first alphabetically goes first!',

    'challenge_logic_height_title': 'Height Challenge',
    'challenge_logic_height_desc': 'The tallest player gets to go first!',

    'challenge_logic_longest_name_title': 'Longest Name',
    'challenge_logic_longest_name_desc':
        'Whoever has the longest full name goes first!',

    'challenge_logic_last_game_played_title': 'Last Game Played',
    'challenge_logic_last_game_played_desc':
        'Whoever played a game most recently goes first!',

    'challenge_logic_most_tokens_title': 'Token Collector',
    'challenge_logic_most_tokens_desc':
        'Whoever owns the most board game pieces goes first!',

    'challenge_logic_left_hand_title': 'Mind Reader',
    'challenge_logic_left_hand_desc':
        'Everyone closes their eyes and picks a token without looking. Whoever draws the highest number goes first.',

    'challenge_luck_flip_coin_title': 'Coin Flip',
    'challenge_luck_flip_coin_desc':
        'Flip a coin. Everyone who called it right goes first; if nobody did, the last caller goes first.',

    'challenge_luck_draw_dice_title': 'Dice Showdown',
    'challenge_luck_draw_dice_desc':
        'Roll a die. Ties go to the player who was closest to the right number.',

    'challenge_luck_odd_one_out_title': 'Odd One Out',
    'challenge_luck_odd_one_out_desc':
        'Each player draws one tile and keeps it face down. Whoever has the odd one out reveals first.',

    'challenge_luck_closed_eyes_title': 'Blind Pick',
    'challenge_luck_closed_eyes_desc':
        'Shuffle a small deck. Whoever picks the ace with their eyes closed goes first.',

    'challenge_luck_brain_wave_title': 'Mind Reading',
    'challenge_luck_brain_wave_desc':
        'One player thinks of a number between 1 and 100. Whoever gets closest without peeking goes first.',

    'challenge_creative_draw_something_title': 'Doodle Duel',
    'challenge_creative_draw_something_desc':
        'Everyone sketches the game logo from memory. Whoever guesses the most correctly goes first.',

    'challenge_creative_invent_a_game_title': 'Invent a Game',
    'challenge_creative_invent_a_game_desc':
        'Describe an imaginary game in one sentence. Whoever invents the strangest rule goes first.',

    'challenge_creative_tell_a_story_title': 'Story Time',
    'challenge_creative_tell_a_story_desc':
        'Each player adds one sentence to a story about the game you are about to play.',

    'challenge_creative_pick_a_remix_title': 'Remix It',
    'challenge_creative_pick_a_remix_desc':
        'Whoever suggests the weirdest twist on the rules of tonight\'s game goes first.',
    'challenge_logic_most_wins_title': 'Winning Streak',
    'challenge_logic_most_wins_desc':
        'Whoever has won the most games in this collection goes first!',

    'challenge_luck_card_stack_title': 'Card Stack',
    'challenge_luck_card_stack_desc':
        'Build a stack of cards, one at a time. Whoever completes the stack goes first - and everyone else starts over.',

    'challenge_dare_last_game_story_title': 'War Story',
    'challenge_dare_last_game_story_desc':
        'Whoever lost the most recent game has to tell the story of how it ended. The best story wins and goes first.',

    'challenge_creative_describe_sound_title': 'Blind Description',
    'challenge_creative_describe_sound_desc':
        'Describe tonight\'s game using only adjectives, no nouns allowed. Whoever others understand first goes first.',
    'challenge_dare_double_dare_title': 'Double Dare',
    'challenge_dare_double_dare_desc':
        'Whoever answers "dare" has to do two of them. Chicken is not an option.',

    'challenge_dare_charades_title': 'Charades',
    'challenge_dare_charades_desc':
        'Act out the name of a game without speaking. Whoever guesses it first goes first.',

    'challenge_life_favorite_food_title': 'Favorite Food',
    'challenge_life_favorite_food_desc':
        'Whoever has the most expensive taste in food goes first!',

    'challenge_life_longest_drive_title': 'Longest Trip',
    'challenge_life_longest_drive_desc':
        'Whoever drove the longest distance to get here goes first!',

    'challenge_life_best_story_title': 'Best Story',
    'challenge_life_best_story_desc':
        'Tell a short true story about a game you played. The table picks the best one and that person goes first.',

    'challenge_logic_finger_count_title': 'Hand Count',
    'challenge_logic_finger_count_desc':
        'Everyone shows one hand without looking. Whoever has the most fingers goes first!',

    'challenge_logic_name_letter_title': 'Letter Hunt',
    'challenge_logic_name_letter_desc':
        'Pick a letter. Whoever has the most names containing it at the table goes first.',

    'challenge_logic_most_expensive_title': 'Biggest Spender',
    'challenge_logic_most_expensive_desc':
        'Whoever owns the most expensive board game goes first. No cheating with the one on the table.',

    'challenge_logic_fastest_answer_title': 'Quick Thinker',
    'challenge_logic_fastest_answer_desc':
        'Ask a quick riddle about tonight\'s game. Whoever answers first goes first.',

    'challenge_luck_dice_sum_title': 'Closest to Seven',
    'challenge_luck_dice_sum_desc':
        'Roll two dice. Whoever gets closest to seven without going over goes first.',

    'challenge_luck_in_my_hand_title': 'In My Hand',
    'challenge_luck_in_my_hand_desc':
        'Each player hides a finger in a closed fist. Whoever holds the most goes first.',

    'challenge_luck_roulette_title': 'Roulette',
    'challenge_luck_roulette_desc':
        'Spin for a game mechanic: swap a piece, lose a turn, or steal one. Highest number picks the outcome.',

    'challenge_creative_draw_face_title': 'Draw the Table',
    'challenge_creative_draw_face_desc':
        'Draw the face of the player to your left in ten seconds. Best likeness goes first.',

    'challenge_creative_game_name_title': 'Name That Game',
    'challenge_creative_game_name_desc':
        'Invent the most believable name for a game that does not exist. The table votes.',

    'challenge_creative_sound_effect_title': 'Sound Effect',
    'challenge_creative_sound_effect_desc':
        'Perform the sound of your favourite game. Whoever guesses it first goes first.',

    'challenge_physical_warmest_hands_title': 'Warmest Hands',
    'challenge_physical_warmest_hands_desc':
        'Whoever has the warmest hands goes first. It is a real metric, trust us.',

    'challenge_physical_fastest_reaction_title': 'Fastest Reflex',
    'challenge_physical_fastest_reaction_desc':
        'The host claps without warning. Whoever reacts first goes first.',
  },

  'pt': {
    'challenge_cat_dare': 'Desafio',
    'challenge_cat_life': 'Vida',
    'challenge_cat_logic': 'Lógica',
    'challenge_cat_physical': 'Físico',
    'challenge_cat_food': 'Comida',
    'challenge_cat_luck': 'Sorte',
    'challenge_cat_creative': 'Criativo',
    'challenge_cat_tech': 'Tecnologia',
    'challenge_diff_easy': 'Fácil',
    'challenge_diff_medium': 'Médio',
    'challenge_diff_hard': 'Difícil',

    'challenge_dare_cheese_pizza_title': 'Desafio da Pizza',
    'challenge_dare_cheese_pizza_desc':
        'Quem comeu pizza de queijo mais recentemente começa!',

    'challenge_dare_truth_or_dare_title': 'Verdade ou Consequência',
    'challenge_dare_truth_or_dare_desc':
        'Cada um responde "verdade" ou "consequência" ao acaso. Sorteie uma para ver quem ganha a rodada.',

    'challenge_dare_sing_next_song_title': 'Cante Alongado',
    'challenge_dare_sing_next_song_desc':
        'Quem ouviu a última música tocando começa, e tem que cantarolá-la.',

    'challenge_dare_impressions_title': 'Imitações',
    'challenge_dare_impressions_desc':
        'Cada um faz a mímica do nome de um jogo. Quem receber mais acertos começa.',

    'challenge_dare_no_smiling_title': 'Proibido Sorrir',
    'challenge_dare_no_smiling_desc':
        'Quem sorrir primeiro durante este desafio perde e joga por último.',

    'challenge_life_birthday_title': 'Desafio do Aniversário',
    'challenge_life_birthday_desc':
        'Quem tiver o aniversário mais próximo de hoje começa!',

    'challenge_life_travel_title': 'Desafio da Viagem',
    'challenge_life_travel_desc': 'Quem viajou mais longe para chegar aqui começa!',

    'challenge_life_battery_title': 'Desafio do Celular',
    'challenge_life_battery_desc':
        'Quem tiver a menor porcentagem de bateria começa!',

    'challenge_life_pets_title': 'Desafio dos Bichos',
    'challenge_life_pets_desc': 'Quem tiver mais bichos de estimação começa!',

    'challenge_life_shoes_title': 'Desafio do Tênis',
    'challenge_life_shoes_desc': 'Quem estiver com o maior número de calçado começa!',

    'challenge_life_early_bird_title': 'Madrugador',
    'challenge_life_early_bird_desc': 'Quem acordou mais cedo hoje começa!',

    'challenge_life_coffee_title': 'Nível de Cafeína',
    'challenge_life_coffee_desc': 'Quem já tomou mais café hoje começa!',

    'challenge_life_left_handed_title': 'Esquerda ou Direita',
    'challenge_life_left_handed_desc':
        'Quem é canhoto começa. Empate: começa a pessoa à direita.',

    'challenge_life_last_vacation_title': 'Última Viagem',
    'challenge_life_last_vacation_desc':
        'Quem fez a viagem mais recente para mais longe de casa começa!',

    'challenge_logic_alphabet_title': 'Desafio do Alfabeto',
    'challenge_logic_alphabet_desc':
        'O jogador cujo nome vem primeiro no alfabeto começa!',

    'challenge_logic_height_title': 'Desafio da Altura',
    'challenge_logic_height_desc': 'O jogador mais alto começa!',

    'challenge_logic_longest_name_title': 'Nome Mais Longo',
    'challenge_logic_longest_name_desc': 'Quem tiver o nome completo mais longo começa!',

    'challenge_logic_last_game_played_title': 'Último Jogo Jogado',
    'challenge_logic_last_game_played_desc':
        'Quem jogou mais recentemente começa!',

    'challenge_logic_most_tokens_title': 'Colecionador de Peças',
    'challenge_logic_most_tokens_desc':
        'Quem tiver mais peças de jogo de tabuleiro começa!',

    'challenge_logic_left_hand_title': 'Telepata',
    'challenge_logic_left_hand_desc':
        'Todos fecham os olhos e pegam uma peça sem olhar. Quem tirar o maior número começa.',

    'challenge_luck_flip_coin_title': 'Cara ou Coroa',
    'challenge_luck_flip_coin_desc':
        'Jogue uma moeda. Quem acertou começa; se ninguém acertou, o último a chamar joga por último.',

    'challenge_luck_draw_dice_title': 'Disputa de Dados',
    'challenge_luck_draw_dice_desc':
        'Role um dado. O empate vai para quem estava mais perto do número certo.',

    'challenge_luck_odd_one_out_title': 'O Diferente',
    'challenge_luck_odd_one_out_desc':
        'Cada um pega uma peça e mantém virada para baixo. Quem tiver a diferente revela primeiro.',

    'challenge_luck_closed_eyes_title': 'Escolha Cega',
    'challenge_luck_closed_eyes_desc':
        'Embaralhe um baralho pequeno. Quem pegar o às de olhos fechados começa.',

    'challenge_luck_brain_wave_title': 'Leitura Mental',
    'challenge_luck_brain_wave_desc':
        'Um jogador pensa num número de 1 a 100. Quem chegar mais perto sem espiar começa.',

    'challenge_creative_draw_something_title': 'Duelo de Rabiscos',
    'challenge_creative_draw_something_desc':
        'Todos desenham o logotipo do jogo de memória. Quem for adivinhado mais vezes começa.',

    'challenge_creative_invent_a_game_title': 'Invention',
    'challenge_creative_invent_a_game_desc':
        'Descreva um jogo imaginário em uma frase. Quem inventar a regra mais estranha começa.',

    'challenge_creative_tell_a_story_title': 'Hora da História',
    'challenge_creative_tell_a_story_desc':
        'Cada um acrescenta uma frase a uma história sobre o jogo que vão jogar.',

    'challenge_creative_pick_a_remix_title': 'Remix',
    'challenge_creative_pick_a_remix_desc':
        'Quem sugerir a mudança mais maluca nas regras do jogo de hoje começa.',
    'challenge_logic_most_wins_title': 'Sequência de Vitórias',
    'challenge_logic_most_wins_desc':
        'Quem ganhou mais jogos nesta coleção começa!',

    'challenge_luck_card_stack_title': 'Pilha de Cartas',
    'challenge_luck_card_stack_desc':
        'Monte uma pilha de cartas, uma por vez. Quem completar a pilha começa - e todo mundo recomeça.',

    'challenge_dare_last_game_story_title': 'História de Guerra',
    'challenge_dare_last_game_story_desc':
        'Quem perdeu o jogo mais recente conta como ele terminou. A melhor história ganha e começa.',

    'challenge_creative_describe_sound_title': 'Descrição às Cegas',
    'challenge_creative_describe_sound_desc':
        'Descreva o jogo de hoje usando só adjetivos, sem nenhum substantivo. Quem for entendido primeiro começa.',
    'challenge_dare_double_dare_title': 'Dose Duplo',
    'challenge_dare_double_dare_desc':
        'Quem respondeu "consequência" tem que fazer duas. Não vale corningar.',

    'challenge_dare_charades_title': 'Mímicas',
    'challenge_dare_charades_desc':
        'Faça a mímica do nome de um jogo sem falar. Quem adivinhar primeiro começa.',

    'challenge_life_favorite_food_title': 'Comida Favorita',
    'challenge_life_favorite_food_desc':
        'Quem tem o paladar mais caro começa!',

    'challenge_life_longest_drive_title': 'Viagem Mais Longa',
    'challenge_life_longest_drive_desc':
        'Quem dirigiu a maior distância para chegar aqui começa!',

    'challenge_life_best_story_title': 'Melhor História',
    'challenge_life_best_story_desc':
        'Conte uma história curta e real sobre um jogo que você jogou. A mesa escolhe a melhor e essa pessoa começa.',

    'challenge_logic_finger_count_title': 'Contagem de Dedos',
    'challenge_logic_finger_count_desc':
        'Todos mostram uma das mãos sem olhar. Quem tiver mais dedos começa!',

    'challenge_logic_name_letter_title': 'Caça à Letra',
    'challenge_logic_name_letter_desc':
        'Sorteie uma letra. Quem tiver mais nomes na mesa com ela começa.',

    'challenge_logic_most_expensive_title': 'Maior Gastador',
    'challenge_logic_most_expensive_desc':
        'Quem tem o jogo de tabuleiro mais caro começa. Não vale usar o da mesa.',

    'challenge_logic_fastest_answer_title': 'Rápido Pensamento',
    'challenge_logic_fastest_answer_desc':
        'Faça uma pergunta rápida sobre o jogo de hoje. Quem responder primeiro começa.',

    'challenge_luck_dice_sum_title': 'Mais Perto de Sete',
    'challenge_luck_dice_sum_desc':
        'Role dois dados. Quem ficar mais perto de sete sem passar começa.',

    'challenge_luck_in_my_hand_title': 'Na Minha Mão',
    'challenge_luck_in_my_hand_desc':
        'Cada um esconde um dedo no punho fechado. Quem tiver mais começa.',

    'challenge_luck_roulette_title': 'Roleta',
    'challenge_luck_roulette_desc':
        'Gire para uma mecânica: troque uma peça, perca a vez, ou roube uma. O maior número escolhe.',

    'challenge_creative_draw_face_title': 'Desenhe a Mesa',
    'challenge_creative_draw_face_desc':
        'Desenhe o rosto de quem está à sua esquerda em dez segundos. O mais parecido começa.',

    'challenge_creative_game_name_title': 'Nomeie um Jogo',
    'challenge_creative_game_name_desc':
        'Invente o nome mais convincente para um jogo que não existe. A mesa vota.',

    'challenge_creative_sound_effect_title': 'Efeito Sonoro',
    'challenge_creative_sound_effect_desc':
        'Faça o som do seu jogo favorito. Quem adivinhar primeiro começa.',

    'challenge_physical_warmest_hands_title': 'Mãos Mais Quentes',
    'challenge_physical_warmest_hands_desc':
        'Quem tiver as mãos mais quentes começa. É uma métrica real, confia.',

    'challenge_physical_fastest_reaction_title': 'Reflexo Mais Rápido',
    'challenge_physical_fastest_reaction_desc':
        'Quem host estala os dedos sem avisar. Quem reagir primeiro começa.',
  },

  'es': {
    'challenge_cat_dare': 'Reto',
    'challenge_cat_life': 'Vida',
    'challenge_cat_logic': 'Lógica',
    'challenge_cat_physical': 'Físico',
    'challenge_cat_food': 'Comida',
    'challenge_cat_luck': 'Suerte',
    'challenge_cat_creative': 'Creativo',
    'challenge_cat_tech': 'Tecnología',
    'challenge_diff_easy': 'Fácil',
    'challenge_diff_medium': 'Medio',
    'challenge_diff_hard': 'Difícil',

    'challenge_dare_cheese_pizza_title': 'Desafío de la Pizza',
    'challenge_dare_cheese_pizza_desc':
        '¡Quien comió pizza de queso más recientemente empieza!',

    'challenge_dare_truth_or_dare_title': 'Verdad o Reto',
    'challenge_dare_truth_or_dare_desc':
        'Cada uno responde "verdad" o "reto" al azar. Sortea una para ver quién gana la ronda.',

    'challenge_dare_sing_next_song_title': 'Canta conmigo',
    'challenge_dare_sing_next_song_desc':
        'Quien oyó la última canción empieza, y tiene que tararearla.',

    'challenge_dare_impressions_title': 'Imitaciones',
    'challenge_dare_impressions_desc':
        'Cada uno hace mímica del nombre de un juego. Quien reciba más aciertos empieza.',

    'challenge_dare_no_smiling_title': 'Prohibido sonreír',
    'challenge_dare_no_smiling_desc':
        'Quien sonría primero durante este reto pierde y juega al final.',

    'challenge_life_birthday_title': 'Desafío del Cumpleaños',
    'challenge_life_birthday_desc':
        '¡Empieza quien tenga el cumpleaños más cercano a hoy!',

    'challenge_life_travel_title': 'Desafío del Viaje',
    'challenge_life_travel_desc': '¡Quien viajé más lejos para llegar hasta aquí empieza!',

    'challenge_life_battery_title': 'Desafío del Móvil',
    'challenge_life_battery_desc': '¡Empieza quien tenga menos batería!',

    'challenge_life_pets_title': 'Desafío de las Mascotas',
    'challenge_life_pets_desc': '¡Quien tenga más mascotas empieza!',

    'challenge_life_shoes_title': 'Desafío de las Zapatillas',
    'challenge_life_shoes_desc': '¡Empieza quien lleve la talla más grande!',

    'challenge_life_early_bird_title': 'Madrugador',
    'challenge_life_early_bird_desc': '¡Empieza quien se haya despertado más temprano hoy!',

    'challenge_life_coffee_title': 'Nivel de Cafeína',
    'challenge_life_coffee_desc': '¡Empieza quien haya tomado más café hoy!',

    'challenge_life_left_handed_title': 'Izquierda o Derecha',
    'challenge_life_left_handed_desc':
        'Empieza quien sea zurdo. Empate: empieza la persona a su derecha.',

    'challenge_life_last_vacation_title': 'Último Viaje',
    'challenge_life_last_vacation_desc':
        '¡Empieza quien hizo el viaje más reciente más lejos de casa!',

    'challenge_logic_alphabet_title': 'Desafío del Alfabeto',
    'challenge_logic_alphabet_desc':
        '¡Empieza el jugador cuyo nombre va primero en el alfabeto!',

    'challenge_logic_height_title': 'Desafío de la Altura',
    'challenge_logic_height_desc': '¡Empieza el jugador más alto!',

    'challenge_logic_longest_name_title': 'Nombre Más Largo',
    'challenge_logic_longest_name_desc': '¡Empieza quien tenga el nombre completo más largo!',

    'challenge_logic_last_game_played_title': 'Último Juego Jugado',
    'challenge_logic_last_game_played_desc': '¡Empieza quien haya jugado más recientemente!',

    'challenge_logic_most_tokens_title': 'Coleccionista de Fichas',
    'challenge_logic_most_tokens_desc': '¡Empieza quien tenga más piezas de juego!',

    'challenge_logic_left_hand_title': 'Telépata',
    'challenge_logic_left_hand_desc':
        'Todos cierran los ojos y cogen una ficha sin mirar. Quien saque el número más alto empieza.',

    'challenge_luck_flip_coin_title': 'Cara o Cruz',
    'challenge_luck_flip_coin_desc':
        'Lanza una moneda. Quien acertó empieza; si nadie acertó, el último en canta juega al final.',

    'challenge_luck_draw_dice_title': 'Duelo de Dados',
    'challenge_luck_draw_dice_desc':
        'Lanza un dado. El empate va para quien estuviera más cerca del número correcto.',

    'challenge_luck_odd_one_out_title': 'El Diferente',
    'challenge_luck_odd_one_out_desc':
        'Cada uno coge una ficha y la mantiene boca abajo. Quien tenga la diferente la enseña primero.',

    'challenge_luck_closed_eyes_title': 'Elección a Ciegas',
    'challenge_luck_closed_eyes_desc':
        'Baraja una baraja pequeña. Quien coja el as con los ojos cerrados empieza.',

    'challenge_luck_brain_wave_title': 'Lectura Mental',
    'challenge_luck_brain_wave_desc':
        'Un jugador piensa un número del 1 al 100. Quien se acerque más sin espiar empieza.',

    'challenge_creative_draw_something_title': 'Duelo de Bocetos',
    'challenge_creative_draw_something_desc':
        'Todos dibujan el logotipo del juego de memoria. Quien sea acertado más veces empieza.',

    'challenge_creative_invent_a_game_title': 'Invención',
    'challenge_creative_invent_a_game_desc':
        'Describe un juego imaginario en una frase. Quien invente la regla más rara empieza.',

    'challenge_creative_tell_a_story_title': 'Hora del Cuento',
    'challenge_creative_tell_a_story_desc':
        'Cada uno añade una frase a una historia sobre el juego que van a jugar.',

    'challenge_creative_pick_a_remix_title': 'Remezcla',
    'challenge_creative_pick_a_remix_desc':
        'Empieza quien sugiera el cambio más raro en las reglas del juego de hoy.',
    'challenge_logic_most_wins_title': 'Racha de Victorias',
    'challenge_logic_most_wins_desc':
        '¡Empieza quien haya ganado más juegos en esta colección!',

    'challenge_luck_card_stack_title': 'Pila de Cartas',
    'challenge_luck_card_stack_desc':
        'Construye una pila de cartas, de una en una. Quien complete la pila empieza - y todos empiezan de nuevo.',

    'challenge_dare_last_game_story_title': 'Historia de Guerra',
    'challenge_dare_last_game_story_desc':
        'Quien perdió el juego más reciente debe contar cómo terminó. La mejor historia gana y empieza.',

    'challenge_creative_describe_sound_title': 'Descripción a Ciegas',
    'challenge_creative_describe_sound_desc':
        'Describe el juego de hoy usando solo adjetivos, sin sustantivos. Quien se entienda primero empieza.',
    'challenge_dare_double_dare_title': 'Doble Reto',
    'challenge_dare_double_dare_desc':
        'Quien respondió "reto" tiene que hacer dos. Correr no cuenta.',

    'challenge_dare_charades_title': 'Charadas',
    'challenge_dare_charades_desc':
        'Actúa el nombre de un juego sin hablar. Quien lo adivine primero empieza.',

    'challenge_life_favorite_food_title': 'Comida Favorita',
    'challenge_life_favorite_food_desc':
        '¡Empieza quien tenga el paladar más caro!',

    'challenge_life_longest_drive_title': 'Viaje Más Largo',
    'challenge_life_longest_drive_desc':
        '¡Empieza quien haya conducido más distancia hasta aquí!',

    'challenge_life_best_story_title': 'Mejor Historia',
    'challenge_life_best_story_desc':
        'Cuenta una historia corta y real sobre un juego que jugaste. La mesa elige la mejor y esa persona empieza.',

    'challenge_logic_finger_count_title': 'Cuenta de Dedos',
    'challenge_logic_finger_count_desc':
        'Todos muestran una mano sin mirar. ¡Quien tenga más dedos empieza!',

    'challenge_logic_name_letter_title': 'Caza la Letra',
    'challenge_logic_name_letter_desc':
        'Sortea una letra. Quien tenga más nombres en la mesa con ella empieza.',

    'challenge_logic_most_expensive_title': 'Mayor Gastador',
    'challenge_logic_most_expensive_desc':
        'Empieza quien tenga el juego de mesa más caro. No vale usar el de la mesa.',

    'challenge_logic_fastest_answer_title': 'Pensamiento Rápido',
    'challenge_logic_fastest_answer_desc':
        'Haz una pregunta rápida sobre el juego de hoy. Quien responda primero empieza.',

    'challenge_luck_dice_sum_title': 'Más Cerca del Siete',
    'challenge_luck_dice_sum_desc':
        'Lanza dos dados. Quien quede más cerca de siete sin pasarse empieza.',

    'challenge_luck_in_my_hand_title': 'En Mi Mano',
    'challenge_luck_in_my_hand_desc':
        'Cada uno esconde un dedo en el puño cerrado. Quien tenga más empieza.',

    'challenge_luck_roulette_title': 'Ruleta',
    'challenge_luck_roulette_desc':
        'Gira para una mecánica: cambia una pieza, pierde el turno, o roba una. El número más alto elige.',

    'challenge_creative_draw_face_title': 'Dibuja la Mesa',
    'challenge_creative_draw_face_desc':
        'Dibuja la cara del jugador a tu izquierda en diez segundos. El más parecido empieza.',

    'challenge_creative_game_name_title': 'Nombra ese Juego',
    'challenge_creative_game_name_desc':
        'Inventa el nombre más creíble para un juego que no existe. La mesa vota.',

    'challenge_creative_sound_effect_title': 'Efecto de Sonido',
    'challenge_creative_sound_effect_desc':
        'Haz el sonido de tu juego favorito. Quien lo adivine primero empieza.',

    'challenge_physical_warmest_hands_title': 'Manos Más Cálidas',
    'challenge_physical_warmest_hands_desc':
        'Empieza quien tenga las manos más calientes. Es una métrica real, confíanos.',

    'challenge_physical_fastest_reaction_title': 'Reflejo Más Rápido',
    'challenge_physical_fastest_reaction_desc':
        'El anfitrión aplaude sin avisar. Quien reaccione primero empieza.',
  },
};
