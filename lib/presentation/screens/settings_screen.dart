import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/components/components.dart';
import '../../core/theme/app_theme.dart';
import '../../core/i18n/i18n.dart';
import '../../data/services/services.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final BackupService _backupService = BackupService();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  bool _isExporting = false;
  bool _isImporting = false;
  String _deviceName = 'User';

  @override
  void initState() {
    super.initState();
    _getDeviceName();
  }

  Future<void> _getDeviceName() async {
    if (kIsWeb) {
      return;
    }

    try {
      String deviceName = 'User';
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceName = iosInfo.name;
      }
      setState(() {
        _deviceName = deviceName;
      });
    } catch (e) {
      // Keep default 'User' if error
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsProvider = context.watch<SettingsProvider>();
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppHeader(
                  title: l10n.settings,
                  leading: IconActionButton(
                    icon: Icons.arrow_back_ios,
                    isDark: isDark,
                    onTap: () => context.pop(),
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserCard(),
                        const SizedBox(height: 32),
                        _buildSectionTitle(l10n.appearance),
                        const SizedBox(height: 12),
                        _buildAppearanceSection(
                          context,
                          isDark,
                          settingsProvider,
                          l10n,
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle(l10n.dataBackup),
                        const SizedBox(height: 12),
                        _buildBackupSection(context, l10n),
                        const SizedBox(height: 32),
                        _buildSectionTitle(l10n.about),
                        const SizedBox(height: 12),
                        _buildAboutSection(context, isDark, l10n),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                ),
                const BottomTabBar(activeRoute: '/settings'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCard() {
    return ThemeContainer(
      padding: const EdgeInsets.all(20),
      customBackgroundColor: AppColors.primary.withValues(alpha: 0.1),
      customBorderColor: AppColors.primary.withValues(alpha: 0.2),
      child: Row(
        children: [
          ProfileAvatar(name: _deviceName, size: 64),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _deviceName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Consumer<SettingsProvider>(
                  builder: (context, settings, _) {
                    final l10n = AppLocalizations.of(context);
                    return Text(
                      l10n.boardGamesCollector,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.grey,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    bool isDark,
    SettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) {
    return ThemeContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.indigo.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.dark_mode, color: Colors.indigo),
            ),
            title: Text(l10n.darkMode),
            trailing: Switch(
              value: settingsProvider.isDarkMode,
              onChanged: (value) {
                settingsProvider.setDarkMode(value);
              },
              activeColor: AppColors.primary,
            ),
          ),
          Divider(
            height: 1,
            indent: 72,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          ListTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.language, color: Colors.green),
            ),
            title: Text(l10n.language),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.getLanguageDisplayName(settingsProvider.language),
                  style: TextStyle(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ],
            ),
            onTap: () => _showLanguageDialog(context, settingsProvider, l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildBackupSection(BuildContext context, AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ThemeContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.exportImportDesc,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isExporting ? null : () => _exportBackup(context),
                  child: _isExporting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(l10n.exportJson),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isImporting ? null : () => _importBackup(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.grey[200],
                    foregroundColor: isDark
                        ? AppColors.textDark
                        : AppColors.textLight,
                  ),
                  child: _isImporting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? AppColors.textDark : AppColors.textLight,
                            ),
                          ),
                        )
                      : Text(l10n.importJson),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(
    BuildContext context,
    bool isDark,
    AppLocalizations l10n,
  ) {
    return ThemeContainer(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l10n.version),
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ),
          Divider(
            height: 1,
            indent: 72,
            color: isDark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(l10n.privacyPolicy),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/privacy-policy'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isExporting = true);
    try {
      await _backupService.shareBackup();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.backupExported)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.errorExporting}: $e')));
      }
    } finally {
      setState(() => _isExporting = false);
    }
  }

  Future<void> _importBackup(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    setState(() => _isImporting = true);
    try {
      final success = await _backupService.importFromFile();
      if (mounted) {
        if (success) {
          context.read<GameProvider>().loadGames();
          context.read<WishlistProvider>().loadItems();
          context.read<PlayerProvider>().loadPlayers();

          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.backupImported)));
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.importCancelled)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${l10n.errorImporting}: $e')));
      }
    } finally {
      setState(() => _isImporting = false);
    }
  }

  void _showLanguageDialog(
    BuildContext context,
    SettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.selectLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n.englishUs),
              trailing: settingsProvider.language == 'en'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                settingsProvider.setLanguage('en');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(l10n.portuguese),
              trailing: settingsProvider.language == 'pt'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                settingsProvider.setLanguage('pt');
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: Text(l10n.spanish),
              trailing: settingsProvider.language == 'es'
                  ? const Icon(Icons.check, color: AppColors.primary)
                  : null,
              onTap: () {
                settingsProvider.setLanguage('es');
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
