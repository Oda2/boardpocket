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
    if (kIsWeb) return;
    try {
      String deviceName = 'User';
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceName = androidInfo.model;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceName = iosInfo.name;
      }
      setState(() => _deviceName = deviceName);
    } catch (e) {}
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
        child: Column(
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
                    UserCard(
                      name: _deviceName,
                      subtitle: l10n.boardGamesCollector,
                      avatar: ProfileAvatar(name: _deviceName, size: 64),
                    ),
                    const SizedBox(height: 32),
                    _buildAppearanceSection(context, settingsProvider, l10n),
                    const SizedBox(height: 32),
                    _buildBackupSection(l10n),
                    const SizedBox(height: 32),
                    _buildAboutSection(l10n),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            const BottomTabBar(activeRoute: '/settings'),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    SettingsProvider settingsProvider,
    AppLocalizations l10n,
  ) {
    return SettingsSection(
      title: l10n.appearance,
      children: [
        SettingsToggle(
          icon: Icons.dark_mode,
          iconColor: Colors.indigo,
          title: l10n.darkMode,
          value: settingsProvider.isDarkMode,
          onChanged: (value) => settingsProvider.setDarkMode(value),
        ),
        const SettingsDivider(),
        SettingsListTile(
          icon: Icons.language,
          iconColor: Colors.green,
          title: l10n.language,
          subtitle: l10n.getLanguageDisplayName(settingsProvider.language),
          onTap: () => _showLanguageDialog(context, settingsProvider, l10n),
        ),
      ],
    );
  }

  Widget _buildBackupSection(AppLocalizations l10n) {
    return SettingsSection(
      title: l10n.dataBackup,
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.exportImportDesc,
                style: TextStyle(
                  fontSize: 13,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 16),
              SettingsActionButtons(
                buttons: [
                  SettingsActionButton(
                    label: l10n.exportJson,
                    isLoading: _isExporting,
                    onPressed: () => _exportBackup(context),
                  ),
                  SettingsActionButton(
                    label: l10n.importJson,
                    isSecondary: true,
                    isLoading: _isImporting,
                    onPressed: () => _importBackup(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(AppLocalizations l10n) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingsSection(
      title: l10n.about,
      children: [
        SettingsListTile(
          icon: Icons.info_outline,
          iconColor: AppColors.primary,
          title: l10n.version,
          trailing: Text(
            '1.0.0',
            style: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ),
        const SettingsDivider(),
        SettingsListTile(
          icon: Icons.privacy_tip_outlined,
          iconColor: AppColors.primary,
          title: l10n.privacyPolicy,
          onTap: () => context.push('/privacy-policy'),
        ),
      ],
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
