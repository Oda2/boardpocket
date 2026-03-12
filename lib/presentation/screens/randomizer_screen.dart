import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/widgets.dart';

class RandomizerScreen extends StatelessWidget {
  const RandomizerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppHeaderWithBack(
                  title: l10n.gameNight,
                  onAction: () {},
                  actionIcon: Icons.settings,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.chooseYourFate,
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textDark
                                  : AppColors.textLight,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.whoStarts,
                            style: TextStyle(
                              fontSize: 16,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondaryLight,
                            ),
                          ),
                          const SizedBox(height: 32),
                          OptionCard(
                            icon: Icons.casino,
                            title: l10n.randomGamePicker,
                            description: l10n.randomGamePickerDesc,
                            onTap: () => context.push('/randomizer-game'),
                            isPrimary: true,
                          ),
                          const SizedBox(height: 16),
                          OptionCard(
                            icon: Icons.touch_app,
                            title: l10n.fingerPicker,
                            description: l10n.fingerPickerDesc,
                            onTap: () => context.push('/randomizer-finger'),
                          ),
                          const SizedBox(height: 16),
                          OptionCard(
                            icon: Icons.format_list_bulleted,
                            title: l10n.nameDraw,
                            description: l10n.nameDrawDesc,
                            onTap: () => context.push('/randomizer-name'),
                          ),
                          const SizedBox(height: 16),
                          OptionCard(
                            icon: Icons.casino,
                            title: l10n.challenge,
                            description: l10n.challengesDesc,
                            onTap: () => context.push('/randomizer-challenge'),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
                const BottomTabBar(activeRoute: '/randomizer'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
