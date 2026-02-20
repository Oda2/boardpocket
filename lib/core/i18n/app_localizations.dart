import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ??
        AppLocalizations(const Locale('en'));
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'app_name': 'BoardPocket',
      'settings': 'Settings',
      'appearance': 'Appearance',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'english_us': 'English (US)',
      'portuguese': 'Portuguese',
      'spanish': 'Spanish',
      'data_backup': 'Data & Backup',
      'export_import_desc':
          'Export or import your entire collection as a JSON file.',
      'export_json': 'Export JSON',
      'import_json': 'Import JSON',
      'about': 'About',
      'version': 'Version',
      'privacy_policy': 'Privacy Policy',
      'collection': 'Collection',
      'wishlist': 'Wishlist',
      'randomizer': 'Randomizer',
      'name_draw': 'Name Draw',
      'finger_picker': 'Finger Picker',
      'challenge': 'Challenge',
      'add_game': 'Add Game',
      'edit_game': 'Edit Game',
      'title': 'Title',
      'players': 'Players',
      'time': 'Time',
      'category': 'Category',
      'complexity': 'Complexity',
      'description': 'Description',
      'save': 'Save',
      'cancel': 'Cancel',
      'delete': 'Delete',
      'confirm_delete': 'Confirm Delete',
      'delete_game_confirm': 'Are you sure you want to delete this game?',
      'total_plays': 'Total Plays',
      'win_rate': 'Win Rate',
      'last_played': 'Last Played',
      'never': 'Never',
      'board_games_collector': 'Board Games Collector',
      'search_games': 'Search games...',
      'no_games_found': 'No games found',
      'start_collection': 'Start your collection by adding a game',
      'backup_exported': 'Backup exported successfully!',
      'backup_imported': 'Backup imported successfully!',
      'error_exporting': 'Error exporting backup',
      'error_importing': 'Error importing backup',
      'import_cancelled': 'Import cancelled',
      'select_language': 'Select Language',
      'no_games_yet': 'No games yet',
      'tap_to_add_first_game': 'Tap + to add your first game',
      'your_wishlist_is_empty': 'Your wishlist is empty',
      'add_games_you_want': 'Add games you want to buy',
      'all': 'All',
      'game_night': 'Game Night',
      'choose_your_fate': 'Choose your fate',
      'who_starts': 'Who starts the game? Pick a method below.',
      'finger_picker_desc': 'Everyone place a finger on the screen.',
      'name_draw_desc': 'Randomly select from your groups.',
      'challenges_desc': 'Mini-games to decide the winner.',
      'randomly_select_player': 'Randomly select a player',
      'enter_player_name': 'Enter player name...',
      'no_players_yet': 'No players yet',
      'add_players_to_start': 'Add players to start drawing',
      'drawing': 'Drawing...',
      'draw_winner': 'DRAW WINNER',
      'the_winner_is': 'THE WINNER IS',
      'draw_again': 'DRAW AGAIN',
      'game_master': 'Game Master',
      'first_player_decider': 'FIRST PLAYER DECIDER',
      'shuffle_challenge': 'SHUFFLE CHALLENGE',
      'winner_takes_lead': 'The winner takes the lead',
      'new_board_game': 'New Board Game',
      'upload_cover': 'Upload High-Res Cover',
      'game_title': 'Game Title',
      'enter_game_title': 'Enter game title',
      'play_time': 'Play Time',
      'add_to_collection': 'Add to Collection',
      'light': 'Light',
      'medium': 'Medium',
      'heavy': 'Heavy',
      'expert': 'Expert',
      'never_played': 'Never played',
      'add_play_session': 'Add a play session',
      'won': 'Won',
      'lost': 'Lost',
      'days_ago': 'days ago',
      'weeks_ago': 'weeks ago',
      'months_ago': 'months ago',
      'today': 'today',
      'yesterday': 'yesterday',
      'fingers_count': 'fingers',
      'finger': 'finger',
      'fingers': 'fingers',
      'tap_to_add_fingers': 'Tap screen to add fingers',
      'add_more_fingers_or_start': 'Add more fingers or start',
      'start_selection': 'START SELECTION',
      'selecting': 'Selecting...',
      'clear_all': 'Clear all',
      'keep_fingers_pressed': 'Keep fingers pressed!',
      'finger_number_won': 'Finger # won!',
      'play_again': 'PLAY AGAIN',
      'add_at_least_two_fingers': 'Add at least 2 fingers!',
      'seconds': 'SECONDS',
      'winner_selected': 'Winner Selected!',
      'random_game_picker': 'Random Game',
      'pick_random_game': 'PICK RANDOM GAME',
      'pick_again': 'PICK AGAIN',
      'no_games_to_pick': 'No games to pick',
      'add_games_to_use_picker':
          'Add games to your collection to use the picker',
      'tap_to_pick_game': 'Tap the button to pick a random game',
      'game_available': 'game available',
      'games_available': 'games available',
      'tap_card_to_view_details': 'Tap the card to view game details',
      'random_game_picker_desc': 'Let fate choose your next board game.',
      'ranking': 'Ranking',
      'statistics': 'Statistics',
      'games_ranking': 'Games Ranking',
      'add_games_to_see_ranking': 'Add games to see the ranking',
      'no_games_played_yet': 'No games played yet',
      'wins_vs_losses': 'Wins vs Losses',
      'wins': 'Wins',
      'losses': 'Losses',
      'no_plays_recorded': 'No plays recorded',
      'most_played_games': 'Most Played Games',
      'game': 'Game',
      'plays': 'Plays',
      'win_rate_short': 'Win %',
    },
    'pt': {
      'app_name': 'BoardPocket',
      'settings': 'Configurações',
      'appearance': 'Aparência',
      'dark_mode': 'Modo Escuro',
      'language': 'Idioma',
      'english_us': 'Inglês (EUA)',
      'portuguese': 'Português',
      'spanish': 'Espanhol',
      'data_backup': 'Dados e Backup',
      'export_import_desc':
          'Exporte ou importe sua coleção inteira como arquivo JSON.',
      'export_json': 'Exportar JSON',
      'import_json': 'Importar JSON',
      'about': 'Sobre',
      'version': 'Versão',
      'privacy_policy': 'Política de Privacidade',
      'collection': 'Coleção',
      'wishlist': 'Lista de Desejos',
      'randomizer': 'Sorteador',
      'name_draw': 'Sorteio de Nomes',
      'finger_picker': 'Escolha por Toque',
      'challenge': 'Desafio',
      'add_game': 'Adicionar Jogo',
      'edit_game': 'Editar Jogo',
      'title': 'Título',
      'players': 'Jogadores',
      'time': 'Tempo',
      'category': 'Categoria',
      'complexity': 'Complexidade',
      'description': 'Descrição',
      'save': 'Salvar',
      'cancel': 'Cancelar',
      'delete': 'Excluir',
      'confirm_delete': 'Confirmar Exclusão',
      'delete_game_confirm': 'Tem certeza que deseja excluir este jogo?',
      'total_plays': 'Total de Partidas',
      'win_rate': 'Taxa de Vitória',
      'last_played': 'Última Partida',
      'never': 'Nunca',
      'board_games_collector': 'Colecionador de Jogos',
      'search_games': 'Buscar jogos...',
      'no_games_found': 'Nenhum jogo encontrado',
      'start_collection': 'Comece sua coleção adicionando um jogo',
      'backup_exported': 'Backup exportado com sucesso!',
      'backup_imported': 'Backup importado com sucesso!',
      'error_exporting': 'Erro ao exportar backup',
      'error_importing': 'Erro ao importar backup',
      'import_cancelled': 'Importação cancelada',
      'select_language': 'Selecionar Idioma',
      'no_games_yet': 'Nenhum jogo ainda',
      'tap_to_add_first_game': 'Toque em + para adicionar seu primeiro jogo',
      'your_wishlist_is_empty': 'Sua lista de desejos está vazia',
      'add_games_you_want': 'Adicione jogos que você deseja comprar',
      'all': 'Todos',
      'game_night': 'Noite de Jogos',
      'choose_your_fate': 'Escolha seu destino',
      'who_starts': 'Quem começa o jogo? Escolha um método abaixo.',
      'finger_picker_desc': 'Todos coloquem um dedo na tela.',
      'name_draw_desc': 'Selecione aleatoriamente dos seus grupos.',
      'challenges_desc': 'Mini-jogos para decidir o vencedor.',
      'randomly_select_player': 'Selecionar jogador aleatoriamente',
      'enter_player_name': 'Digite o nome do jogador...',
      'no_players_yet': 'Nenhum jogador ainda',
      'add_players_to_start': 'Adicione jogadores para começar o sorteio',
      'drawing': 'Sorteando...',
      'draw_winner': 'SORTEAR VENCEDOR',
      'the_winner_is': 'O VENCEDOR É',
      'draw_again': 'SORTEAR NOVAMENTE',
      'game_master': 'Mestre do Jogo',
      'first_player_decider': 'DECIDIR PRIMEIRO JOGADOR',
      'shuffle_challenge': 'DESAFIO EMBARALHADO',
      'winner_takes_lead': 'O vencedor começa',
      'new_board_game': 'Novo Jogo de Tabuleiro',
      'upload_cover': 'Enviar Capa em Alta Resolução',
      'game_title': 'Título do Jogo',
      'enter_game_title': 'Digite o título do jogo',
      'play_time': 'Tempo de Jogo',
      'add_to_collection': 'Adicionar à Coleção',
      'light': 'Leve',
      'medium': 'Médio',
      'heavy': 'Pesado',
      'expert': 'Especialista',
      'never_played': 'Nunca jogado',
      'add_play_session': 'Adicionar uma sessão de jogo',
      'won': 'Ganhou',
      'lost': 'Perdeu',
      'days_ago': 'dias atrás',
      'weeks_ago': 'semanas atrás',
      'months_ago': 'meses atrás',
      'today': 'hoje',
      'yesterday': 'ontem',
      'fingers_count': 'dedos',
      'finger': 'dedo',
      'fingers': 'dedos',
      'tap_to_add_fingers': 'Toque na tela para adicionar dedos',
      'add_more_fingers_or_start': 'Adicione mais dedos ou inicie',
      'start_selection': 'INICIAR SELEÇÃO',
      'selecting': 'Selecionando...',
      'clear_all': 'Limpar tudo',
      'keep_fingers_pressed': 'Mantenha os dedos pressionados!',
      'finger_number_won': 'Dedo # venceu!',
      'play_again': 'JOGAR NOVAMENTE',
      'add_at_least_two_fingers': 'Adicione pelo menos 2 dedos!',
      'seconds': 'SEGUNDOS',
      'winner_selected': 'Vencedor Selecionado!',
      'random_game_picker': 'Jogo Aleatório',
      'pick_random_game': 'SORTEAR JOGO',
      'pick_again': 'SORTEAR NOVAMENTE',
      'no_games_to_pick': 'Nenhum jogo para sortear',
      'add_games_to_use_picker':
          'Adicione jogos à sua coleção para usar o sorteador',
      'tap_to_pick_game': 'Toque o botão para sortear um jogo aleatório',
      'game_available': 'jogo disponível',
      'games_available': 'jogos disponíveis',
      'tap_card_to_view_details': 'Toque no card para ver detalhes do jogo',
      'random_game_picker_desc': 'Deixe o destino escolher seu próximo jogo.',
      'ranking': 'Ranking',
      'statistics': 'Estatísticas',
      'games_ranking': 'Ranking de Jogos',
      'add_games_to_see_ranking': 'Adicione jogos para ver o ranking',
      'no_games_played_yet': 'Nenhum jogo jogado ainda',
      'wins_vs_losses': 'Vitórias vs Derrotas',
      'wins': 'Vitórias',
      'losses': 'Derrotas',
      'no_plays_recorded': 'Nenhuma partida registrada',
      'most_played_games': 'Jogos Mais Jogados',
      'game': 'Jogo',
      'plays': 'Partidas',
      'win_rate_short': 'Vitória %',
    },
    'es': {
      'app_name': 'BoardPocket',
      'settings': 'Configuración',
      'appearance': 'Apariencia',
      'dark_mode': 'Modo Oscuro',
      'language': 'Idioma',
      'english_us': 'Inglés (EE.UU.)',
      'portuguese': 'Portugués',
      'spanish': 'Español',
      'data_backup': 'Datos y Respaldo',
      'export_import_desc':
          'Exporta o importa tu colección completa como archivo JSON.',
      'export_json': 'Exportar JSON',
      'import_json': 'Importar JSON',
      'about': 'Acerca de',
      'version': 'Versión',
      'privacy_policy': 'Política de Privacidad',
      'collection': 'Colección',
      'wishlist': 'Lista de Deseos',
      'randomizer': 'Aleatorio',
      'name_draw': 'Sorteo de Nombres',
      'finger_picker': 'Selector de Dedos',
      'challenge': 'Desafío',
      'add_game': 'Agregar Juego',
      'edit_game': 'Editar Juego',
      'title': 'Título',
      'players': 'Jugadores',
      'time': 'Tiempo',
      'category': 'Categoría',
      'complexity': 'Complejidad',
      'description': 'Descripción',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'delete': 'Eliminar',
      'confirm_delete': 'Confirmar Eliminación',
      'delete_game_confirm': '¿Estás seguro de que deseas eliminar este juego?',
      'total_plays': 'Total de Partidas',
      'win_rate': 'Tasa de Victoria',
      'last_played': 'Última Partida',
      'never': 'Nunca',
      'board_games_collector': 'Coleccionista de Juegos',
      'search_games': 'Buscar juegos...',
      'no_games_found': 'No se encontraron juegos',
      'start_collection': 'Comienza tu colección agregando un juego',
      'backup_exported': '¡Respaldo exportado exitosamente!',
      'backup_imported': '¡Respaldo importado exitosamente!',
      'error_exporting': 'Error al exportar respaldo',
      'error_importing': 'Error al importar respaldo',
      'import_cancelled': 'Importación cancelada',
      'select_language': 'Seleccionar Idioma',
      'no_games_yet': 'Aún no hay juegos',
      'tap_to_add_first_game': 'Toca + para agregar tu primer juego',
      'your_wishlist_is_empty': 'Tu lista de deseos está vacía',
      'add_games_you_want': 'Agrega juegos que deseas comprar',
      'all': 'Todos',
      'game_night': 'Noche de Juegos',
      'choose_your_fate': 'Elige tu destino',
      'who_starts': '¿Quién empieza el juego? Elige un método abajo.',
      'finger_picker_desc': 'Todos pongan un dedo en la pantalla.',
      'name_draw_desc': 'Selecciona aleatoriamente de tus grupos.',
      'challenges_desc': 'Mini-juegos para decidir el ganador.',
      'randomly_select_player': 'Seleccionar jugador aleatoriamente',
      'enter_player_name': 'Ingresa el nombre del jugador...',
      'no_players_yet': 'Aún no hay jugadores',
      'add_players_to_start': 'Agrega jugadores para empezar el sorteo',
      'drawing': 'Sorteando...',
      'draw_winner': 'SORTEAR GANADOR',
      'the_winner_is': 'EL GANADOR ES',
      'draw_again': 'SORTEAR DE NUEVO',
      'game_master': 'Maestro del Juego',
      'first_player_decider': 'DECIDIR PRIMER JUGADOR',
      'shuffle_challenge': 'DESAFÍO ALEATORIO',
      'winner_takes_lead': 'El ganador empieza',
      'new_board_game': 'Nuevo Juego de Mesa',
      'upload_cover': 'Subir Portada en Alta Resolución',
      'game_title': 'Título del Juego',
      'enter_game_title': 'Ingresa el título del juego',
      'play_time': 'Tiempo de Juego',
      'add_to_collection': 'Agregar a la Colección',
      'light': 'Ligero',
      'medium': 'Medio',
      'heavy': 'Pesado',
      'expert': 'Experto',
      'never_played': 'Nunca jugado',
      'add_play_session': 'Agregar una sesión de juego',
      'won': 'Ganó',
      'lost': 'Perdió',
      'days_ago': 'días atrás',
      'weeks_ago': 'semanas atrás',
      'months_ago': 'meses atrás',
      'today': 'hoy',
      'yesterday': 'ayer',
      'fingers_count': 'dedos',
      'finger': 'dedo',
      'fingers': 'dedos',
      'tap_to_add_fingers': 'Toca la pantalla para agregar dedos',
      'add_more_fingers_or_start': 'Agrega más dedos o inicia',
      'start_selection': 'INICIAR SELECCIÓN',
      'selecting': 'Seleccionando...',
      'clear_all': 'Limpiar todo',
      'keep_fingers_pressed': '¡Mantén los dedos presionados!',
      'finger_number_won': '¡Dedo # ganó!',
      'play_again': 'JUGAR DE NUEVO',
      'add_at_least_two_fingers': '¡Agrega al menos 2 dedos!',
      'seconds': 'SEGUNDOS',
      'winner_selected': '¡Ganador Seleccionado!',
      'random_game_picker': 'Juego Aleatorio',
      'pick_random_game': 'ELEGIR JUEGO',
      'pick_again': 'ELEGIR OTRO',
      'no_games_to_pick': 'No hay juegos para elegir',
      'add_games_to_use_picker':
          'Agrega juegos a tu colección para usar el selector',
      'tap_to_pick_game': 'Toca el botón para elegir un juego aleatorio',
      'game_available': 'juego disponible',
      'games_available': 'juegos disponibles',
      'tap_card_to_view_details': 'Toca la tarjeta para ver detalles del juego',
      'random_game_picker_desc': 'Deja que el destino elija tu próximo juego.',
      'ranking': 'Ranking',
      'statistics': 'Estadísticas',
      'games_ranking': 'Ranking de Juegos',
      'add_games_to_see_ranking': 'Agrega juegos para ver el ranking',
      'no_games_played_yet': 'Aún no hay juegos jugados',
      'wins_vs_losses': 'Victorias vs Derrotas',
      'wins': 'Victorias',
      'losses': 'Derrotas',
      'no_plays_recorded': 'No hay partidas registradas',
      'most_played_games': 'Juegos Más Jugados',
      'game': 'Juego',
      'plays': 'Partidas',
      'win_rate_short': 'Victoria %',
    },
  };

  String getString(String key) {
    final langCode = locale.languageCode ?? 'en';
    final values = _localizedValues[langCode] ?? _localizedValues['en'];
    return values?[key] ?? 'Missing translation: $key';
  }

  String get appName => getString('app_name');
  String get settings => getString('settings');
  String get appearance => getString('appearance');
  String get darkMode => getString('dark_mode');
  String get language => getString('language');
  String get englishUs => getString('english_us');
  String get portuguese => getString('portuguese');
  String get spanish => getString('spanish');
  String get dataBackup => getString('data_backup');
  String get exportImportDesc => getString('export_import_desc');
  String get exportJson => getString('export_json');
  String get importJson => getString('import_json');
  String get about => getString('about');
  String get version => getString('version');
  String get privacyPolicy => getString('privacy_policy');
  String get collection => getString('collection');
  String get wishlist => getString('wishlist');
  String get randomizer => getString('randomizer');
  String get nameDraw => getString('name_draw');
  String get fingerPicker => getString('finger_picker');
  String get challenge => getString('challenge');
  String get addGame => getString('add_game');
  String get editGame => getString('edit_game');
  String get title => getString('title');
  String get players => getString('players');
  String get time => getString('time');
  String get category => getString('category');
  String get complexity => getString('complexity');
  String get description => getString('description');
  String get save => getString('save');
  String get cancel => getString('cancel');
  String get delete => getString('delete');
  String get confirmDelete => getString('confirm_delete');
  String get deleteGameConfirm => getString('delete_game_confirm');
  String get totalPlays => getString('total_plays');
  String get winRate => getString('win_rate');
  String get lastPlayed => getString('last_played');
  String get never => getString('never');
  String get boardGamesCollector => getString('board_games_collector');
  String get searchGames => getString('search_games');
  String get noGamesFound => getString('no_games_found');
  String get startCollection => getString('start_collection');
  String get backupExported => getString('backup_exported');
  String get backupImported => getString('backup_imported');
  String get errorExporting => getString('error_exporting');
  String get errorImporting => getString('error_importing');
  String get importCancelled => getString('import_cancelled');
  String get selectLanguage => getString('select_language');

  // Collection Screen
  String get noGamesYet => getString('no_games_yet');
  String get tapToAddFirstGame => getString('tap_to_add_first_game');

  // Wishlist Screen
  String get all => getString('all');
  String get yourWishlistIsEmpty => getString('your_wishlist_is_empty');
  String get addGamesYouWant => getString('add_games_you_want');

  // Randomizer Screen
  String get gameNight => getString('game_night');
  String get chooseYourFate => getString('choose_your_fate');
  String get whoStarts => getString('who_starts');
  String get fingerPickerDesc => getString('finger_picker_desc');
  String get nameDrawDesc => getString('name_draw_desc');
  String get challengesDesc => getString('challenges_desc');

  // Name Draw Screen
  String get randomlySelectPlayer => getString('randomly_select_player');
  String get enterPlayerName => getString('enter_player_name');
  String get noPlayersYet => getString('no_players_yet');
  String get addPlayersToStart => getString('add_players_to_start');
  String get drawing => getString('drawing');
  String get drawWinner => getString('draw_winner');
  String get theWinnerIs => getString('the_winner_is');
  String get drawAgain => getString('draw_again');

  // Challenge Screen
  String get gameMaster => getString('game_master');
  String get firstPlayerDecider => getString('first_player_decider');
  String get shuffleChallenge => getString('shuffle_challenge');
  String get winnerTakesLead => getString('winner_takes_lead');

  // Add Game Screen
  String get newBoardGame => getString('new_board_game');
  String get uploadCover => getString('upload_cover');
  String get gameTitle => getString('game_title');
  String get enterGameTitle => getString('enter_game_title');
  String get playTime => getString('play_time');
  String get addToCollection => getString('add_to_collection');
  String get light => getString('light');
  String get medium => getString('medium');
  String get heavy => getString('heavy');
  String get expert => getString('expert');

  // Game Detail Screen
  String get neverPlayed => getString('never_played');
  String get addPlaySession => getString('add_play_session');
  String get won => getString('won');
  String get lost => getString('lost');
  String get daysAgo => getString('days_ago');
  String get weeksAgo => getString('weeks_ago');
  String get monthsAgo => getString('months_ago');
  String get today => getString('today');
  String get yesterday => getString('yesterday');

  // Finger Picker Screen
  String get fingersCount => getString('fingers_count');
  String get finger => getString('finger');
  String get fingers => getString('fingers');
  String get tapToAddFingers => getString('tap_to_add_fingers');
  String get addMoreFingersOrStart => getString('add_more_fingers_or_start');
  String get startSelection => getString('start_selection');
  String get clearAll => getString('clear_all');
  String get selecting => getString('selecting');
  String get keepFingersPressed => getString('keep_fingers_pressed');
  String get fingerNumberWon => getString('finger_number_won');
  String get playAgain => getString('play_again');
  String get addAtLeastTwoFingers => getString('add_at_least_two_fingers');
  String get seconds => getString('seconds');
  String get winnerSelected => getString('winner_selected');

  // Random Game Picker Screen
  String get randomGamePicker => getString('random_game_picker');
  String get pickRandomGame => getString('pick_random_game');
  String get pickAgain => getString('pick_again');
  String get noGamesToPick => getString('no_games_to_pick');
  String get addGamesToUsePicker => getString('add_games_to_use_picker');
  String get tapToPickGame => getString('tap_to_pick_game');
  String get gameAvailable => getString('game_available');
  String get gamesAvailable => getString('games_available');
  String get tapCardToViewDetails => getString('tap_card_to_view_details');
  String get randomGamePickerDesc => getString('random_game_picker_desc');

  // Ranking Screen
  String get ranking => getString('ranking');
  String get statistics => getString('statistics');
  String get gamesRanking => getString('games_ranking');
  String get addGamesToSeeRanking => getString('add_games_to_see_ranking');
  String get noGamesPlayedYet => getString('no_games_played_yet');
  String get winsVsLosses => getString('wins_vs_losses');
  String get wins => getString('wins');
  String get losses => getString('losses');
  String get noPlaysRecorded => getString('no_plays_recorded');
  String get mostPlayedGames => getString('most_played_games');
  String get game => getString('game');
  String get plays => getString('plays');
  String get winRateShort => getString('win_rate_short');

  String getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return englishUs;
      case 'pt':
        return portuguese;
      case 'es':
        return spanish;
      default:
        return englishUs;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'pt', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
