import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../app_button.dart';

class FormScreenHeader extends StatelessWidget {
  final String title;
  final String? cancelText;
  final VoidCallback? onBack;
  final VoidCallback? onCancel;

  const FormScreenHeader({
    super.key,
    required this.title,
    this.cancelText,
    this.onBack,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(
            onPressed: onCancel ?? () => Navigator.of(context).pop(),
            child: Text(cancelText ?? 'Cancel'),
          ),
        ],
      ),
    );
  }
}

class FormScreenFooter extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDark;

  const FormScreenFooter({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.isDark = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
                .withValues(alpha: 0),
          ],
        ),
      ),
      child: SafeArea(
        child: AppButton(label: label, icon: icon, onPressed: onPressed),
      ),
    );
  }
}
