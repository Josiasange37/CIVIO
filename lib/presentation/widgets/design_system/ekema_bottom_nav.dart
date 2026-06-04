import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EkemaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const EkemaBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const _items = [
    (Icons.explore_outlined, Icons.explore, 'Explorer'),
    (Icons.chat_bubble_outline, Icons.chat_bubble, 'Dialogue'),
    (Icons.route_outlined, Icons.route, 'Plan'),
    (Icons.edit_outlined, Icons.edit, 'Rédiger'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(EkemaSpacing.lg, EkemaSpacing.md, EkemaSpacing.lg, EkemaSpacing.xl),
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        border: Border(top: BorderSide(color: EkemaColors.border.withValues(alpha: 0.8))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(_items.length, (index) {
          final active = index == currentIndex;
          final item = _items[index];
          return InkWell(
            onTap: onTap != null ? () => onTap!(index) : null,
            borderRadius: BorderRadius.circular(EkemaRadius.pill),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.md, vertical: EkemaSpacing.sm),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    active ? item.$2 : item.$1,
                    size: 24,
                    color: active ? EkemaColors.brand : EkemaColors.textSecondary,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.$3,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active ? EkemaColors.brand : EkemaColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
