import 'package:flutter/material.dart';

class IOSHomeIndicator extends StatelessWidget {
  const IOSHomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          width: 128,
          height: 5,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.grey[700]?.withValues(alpha: 0.5)
                : Colors.grey[400]?.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(9999),
          ),
        ),
      ),
    );
  }
}
