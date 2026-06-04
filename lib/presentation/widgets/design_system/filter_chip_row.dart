import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FilterChipRow extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int>? onSelected;

  const FilterChipRow({
    super.key,
    required this.labels,
    this.selectedIndex = 0,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: EkemaSpacing.sm),
        itemBuilder: (context, index) {
          final selected = index == selectedIndex;
          return GestureDetector(
            onTap: () => onSelected?.call(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? EkemaColors.textPrimary : EkemaColors.subtle,
                borderRadius: BorderRadius.circular(EkemaRadius.pill),
                border: Border.all(
                  color: selected ? EkemaColors.textPrimary : EkemaColors.border,
                ),
              ),
              child: Text(
                labels[index],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: selected ? EkemaColors.textInverse : EkemaColors.textPrimary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
