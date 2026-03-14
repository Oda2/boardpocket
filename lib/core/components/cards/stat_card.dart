import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../theme_container.dart';
import '../app_button.dart';

class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color? valueColor;
  final bool useSecondaryBackground;

  const StatCard({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
    this.useSecondaryBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ThemeContainer(
      padding: const EdgeInsets.all(20),
      useSecondaryBackground: useSecondaryBackground,
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class ActionButtonsRow extends StatelessWidget {
  final List<ActionButtonConfig> buttons;

  const ActionButtonsRow({super.key, required this.buttons});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: buttons.asMap().entries.map((entry) {
        final index = entry.key;
        final button = entry.value;
        final isLast = index == buttons.length - 1;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: isLast ? 0 : 16),
            child: AppButton(
              label: button.label,
              icon: button.icon,
              isSecondary: button.isSecondary,
              onPressed: button.onPressed,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class ActionButtonConfig {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isSecondary;

  const ActionButtonConfig({
    required this.label,
    this.icon,
    this.onPressed,
    this.isSecondary = false,
  });
}

class DateBox extends StatelessWidget {
  final DateTime? date;
  final String? placeholder;

  const DateBox({super.key, this.date, this.placeholder});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date != null ? _getMonthAbbreviation(date!) : 'N/A',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            date != null ? '${date!.day}' : '-',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _getMonthAbbreviation(DateTime date) {
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC',
    ];
    return months[date.month - 1];
  }
}
