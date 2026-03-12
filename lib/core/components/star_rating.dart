import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StarRating extends StatelessWidget {
  final int value;
  final int max;
  final double size;
  final ValueChanged<int>? onChanged;

  const StarRating({
    super.key,
    required this.value,
    this.max = 5,
    this.size = 32,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(max, (index) {
          final isSelected = index < value;
          return GestureDetector(
            onTap: onChanged != null ? () => onChanged!(index + 1) : null,
            child: Icon(
              Icons.star,
              size: size,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          );
        }),
      ),
    );
  }
}
