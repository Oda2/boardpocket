import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';

/// Lets the user pick which dice to roll (d4, d6, d8, d10, d12, d20, d100)
/// and see every individual result plus the total.
class DiceRollerScreen extends StatelessWidget {
  const DiceRollerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dice = context.watch<DiceProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, l10n, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSelector(context, l10n, dice),
                    const SizedBox(height: 24),
                    _buildPool(context, l10n, dice, isDark),
                    const SizedBox(height: 24),
                    _buildResult(context, l10n, dice, isDark),
                  ],
                ),
              ),
            ),
            _buildFooter(context, l10n, dice),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    AppLocalizations l10n,
    bool isDark,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Expanded so the header never overflows on narrow screens.
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.diceRoller,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.diceRollerDesc,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          IconActionButton(
            icon: Icons.close,
            isDark: isDark,
            onTap: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSelector(
    BuildContext context,
    AppLocalizations l10n,
    DiceProvider dice,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selectDice,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.selectDiceDesc,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final sides in kDieTypes)
              _DieChip(
                sides: sides,
                count: dice.pool.countOf(sides),
                onAdd: () => context.read<DiceProvider>().addDie(sides),
                onRemove: () => context.read<DiceProvider>().removeDie(sides),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildPool(
    BuildContext context,
    AppLocalizations l10n,
    DiceProvider dice,
    bool isDark,
  ) {
    if (dice.pool.isEmpty) {
      return ThemeContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.touch_app, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.noDiceSelected,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.yourPool,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.read<DiceProvider>().clearPool(),
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text(l10n.clearAll),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final sides in dice.pool.selectedTypes)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  '${dice.pool.countOf(sides)}x d$sides',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildResult(
    BuildContext context,
    AppLocalizations l10n,
    DiceProvider dice,
    bool isDark,
  ) {
    if (dice.lastRoll.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l10n.rollResult,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            if (dice.rollNumber > 0)
              Text(
                '${l10n.roll} #${dice.rollNumber}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ThemeContainer(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  for (final die in dice.lastRoll)
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.6, end: 1),
                      duration: const Duration(milliseconds: 250),
                      builder: (context, value, child) =>
                          Transform.scale(scale: value, child: child),
                      child: _DieResult(die: die),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),
              Text(l10n.total, style: const TextStyle(fontSize: 12)),
              const SizedBox(height: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: dice.lastTotal.toDouble()),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOut,
                builder: (context, value, _) => Text(
                  '${value.round()}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AppLocalizations l10n,
    DiceProvider dice,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: SizedBox(
        width: double.infinity,
        child: AppButton(
          label: dice.isRolling ? l10n.rolling : l10n.rollDice,
          icon: Icons.casino,
          onPressed: dice.canRoll
              ? () => context.read<DiceProvider>().roll()
              : null,
        ),
      ),
    );
  }
}

class _DieChip extends StatelessWidget {
  final int sides;
  final int count;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _DieChip({
    required this.sides,
    required this.count,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final selected = count > 0;
    return InputChip(
      selected: selected,
      label: Text(selected ? 'd$sides x$count' : 'd$sides'),
      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      labelStyle: TextStyle(
        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
        color: selected ? AppColors.primary : null,
      ),
      side: selected
          ? BorderSide(color: AppColors.primary.withValues(alpha: 0.5))
          : null,
      onSelected: (_) => onAdd(),
      onDeleted: selected ? onRemove : null,
      deleteIcon: const Icon(Icons.remove_circle_outline, size: 18),
      deleteButtonTooltipMessage: 'Remove d$sides',
    );
  }
}

class _DieResult extends StatelessWidget {
  final DieRoll die;

  const _DieResult({required this.die});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${die.value}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Text(
            'd${die.sides}',
            style: TextStyle(
              fontSize: 9,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }
}
