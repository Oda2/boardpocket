import 'package:flutter/material.dart';
import '../section_label.dart';

class FormSection extends StatelessWidget {
  final String label;
  final Widget child;
  final Widget? trailing;
  final double spacing;

  const FormSection({
    super.key,
    required this.label,
    required this.child,
    this.trailing,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionLabel(text: label, trailing: trailing),
        SizedBox(height: spacing),
        child,
      ],
    );
  }
}

class FormRow extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const FormRow({super.key, required this.children, this.spacing = 16});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: children.asMap().entries.map((entry) {
        final isLast = entry.key == children.length - 1;
        return Expanded(child: entry.value);
      }).toList(),
    );
  }
}
