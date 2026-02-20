import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../core/i18n/i18n.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final locale = Localizations.localeOf(context).languageCode;

    final content = _getContent(locale);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_ios),
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.privacyPolicy,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: content
                      .map((section) => _buildSection(context, section, isDark))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    Map<String, String> section,
    bool isDark,
  ) {
    final title = section['title']!;
    final contentText = section['content']!;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            contentText,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, String>> _getContent(String locale) {
    switch (locale) {
      case 'pt':
        return _contentPt;
      case 'es':
        return _contentEs;
      default:
        return _contentEn;
    }
  }

  static final List<Map<String, String>> _contentEn = [
    {
      'title': 'Introduction',
      'content':
          'BoardPocket respects your privacy. This Privacy Policy explains how we collect, use, and protect your personal information when you use our application.',
    },
    {
      'title': 'Data We Collect',
      'content':
          'We collect only the data necessary to provide our services:\n\n• Game collection data (titles, players, play time, categories)\n• Wishlist information\n• Play session records (wins/losses, dates)\n• Device information for backup functionality',
    },
    {
      'title': 'How We Use Your Data',
      'content':
          'Your data is used exclusively for:\n\n• Managing your board game collection\n• Tracking play sessions and statistics\n• Providing randomizer features\n• Enabling data backup and restore',
    },
    {
      'title': 'Data Storage',
      'content':
          'Your personal data (games, wishlists, play sessions) is stored locally on your device. We do not upload your personal data to external servers.',
    },
    {
      'title': 'Firebase & Crashlytics',
      'content':
          'We use Firebase Crashlytics to monitor and fix app crashes. When a crash occurs, the following anonymous data may be sent to Firebase servers:\n\n• Device model and OS version\n• App version\n• Crash traces and stack logs\n\nThis data is anonymous and does not contain your personal game data. It is used solely to improve app stability.',
    },
    {
      'title': 'Your Rights',
      'content':
          'You have the right to:\n\n• Access your personal data\n• Delete all your data (via app settings)\n• Export your data in JSON format\n\nYou can delete all data through the app\'s settings menu.',
    },
    {
      'title': 'Contact',
      'content':
          'If you have questions about this Privacy Policy, please contact us through the app\'s support channels.',
    },
    {'title': 'Last Updated', 'content': 'February 2026'},
  ];

  static final List<Map<String, String>> _contentPt = [
    {
      'title': 'Introdução',
      'content':
          'BoardPocket respeita sua privacidade. Esta Política de Privacidade explica como coletamos, usamos e protegemos suas informações pessoais ao usar nosso aplicativo.',
    },
    {
      'title': 'Dados que Coletamos',
      'content':
          'Coletamos apenas os dados necessários para fornecer nossos serviços:\n\n• Dados da coleção de jogos (títulos, jogadores, tempo de jogo, categorias)\n• Informações da lista de desejos\n• Registros de sessões de jogo (vitórias/derrotas, datas)\n• Informações do dispositivo para funcionalidade de backup',
    },
    {
      'title': 'Como Usamos Seus Dados',
      'content':
          'Seus dados são usados exclusivamente para:\n\n• Gerenciar sua coleção de jogos de tabuleiro\n• Rastrear sessões de jogo e estatísticas\n• Fornecer funcionalidades de sorteio\n• Habilitar backup e restauração de dados',
    },
    {
      'title': 'Armazenamento de Dados',
      'content':
          'Seus dados pessoais (jogos, listas de desejos, sessões de jogo) são armazenados localmente em seu dispositivo. Não enviamos seus dados pessoais para servidores externos.',
    },
    {
      'title': 'Firebase e Crashlytics',
      'content':
          'Usamos o Firebase Crashlytics para monitorar e corrigir travamentos do aplicativo. Quando ocorre um travamento, os seguintes dados anônimos podem ser enviados para os servidores do Firebase:\n\n• Modelo do dispositivo e versão do sistema operacional\n• Versão do aplicativo\n• Rastros de erro e logs de falha\n\nEsses dados são anônimos e não contêm seus dados pessoais de jogos. Eles são usados apenas para melhorar a estabilidade do aplicativo.',
    },
    {
      'title': 'Seus Direitos',
      'content':
          'Você tem o direito de:\n\n• Acessar seus dados pessoais\n• Excluir todos os seus dados (via configurações do app)\n• Exportar seus dados em formato JSON\n\nVocê pode excluir todos os dados através do menu de configurações do aplicativo.',
    },
    {
      'title': 'Contato',
      'content':
          'Se você tiver dúvidas sobre esta Política de Privacidade, entre em contato conosco através dos canais de suporte do aplicativo.',
    },
    {'title': 'Última Atualização', 'content': 'Fevereiro de 2026'},
  ];

  static final List<Map<String, String>> _contentEs = [
    {
      'title': 'Introducción',
      'content':
          'BoardPocket respeta tu privacidad. Esta Política de Privacidad explica cómo recopilamos, usamos y protegemos tu información personal cuando usas nuestra aplicación.',
    },
    {
      'title': 'Datos que Recopilamos',
      'content':
          'Solo recopilamos los datos necesarios para proporcionar nuestros servicios:\n\n• Datos de tu colección de juegos (títulos, jugadores, tiempo de juego, categorías)\n• Información de la lista de deseos\n• Registros de sesiones de juego (victorias/derrotas, fechas)\n• Información del dispositivo para funcionalidad de respaldo',
    },
    {
      'title': 'Cómo Usamos Tus Datos',
      'content':
          'Tus datos se usan exclusivamente para:\n\n• Gestionar tu colección de juegos de mesa\n• Rastrear sesiones de juego y estadísticas\n• Proporcionar funciones de aleatorización\n• Habilitar respaldo y restauración de datos',
    },
    {
      'title': 'Almacenamiento de Datos',
      'content':
          'Tus datos personales (juegos, listas de deseos, sesiones de juego) se almacenan localmente en tu dispositivo. No subimos tus datos personales a servidores externos.',
    },
    {
      'title': 'Firebase y Crashlytics',
      'content':
          'Usamos Firebase Crashlytics para monitorear y corregir fallas de la aplicación. Cuando ocurre una falla, los siguientes datos anónimos pueden ser enviados a los servidores de Firebase:\n\n• Modelo del dispositivo y versión del sistema operativo\n• Versión de la aplicación\n• Rastreos de error y registros de falla\n\nEstos datos son anónimos y no contienen tus datos personales de juegos. Se usan únicamente para mejorar la estabilidad de la aplicación.',
    },
    {
      'title': 'Tus Derechos',
      'content':
          'Tienes derecho a:\n\n• Acceder a tus datos personales\n• Eliminar todos tus datos (a través de la configuración de la app)\n• Exportar tus datos en formato JSON\n\nPuedes eliminar todos los datos a través del menú de configuración de la aplicación.',
    },
    {
      'title': 'Contacto',
      'content':
          'Si tienes preguntas sobre esta Política de Privacidad, contáctanos a través de los canales de soporte de la aplicación.',
    },
    {'title': 'Última Actualización', 'content': 'Febrero de 2026'},
  ];
}
