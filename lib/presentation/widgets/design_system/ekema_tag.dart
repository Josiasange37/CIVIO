import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum EkemaTagVariant { cost, time, doc, defaultTag }

class EkemaTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final EkemaTagVariant variant;

  const EkemaTag({
    super.key,
    required this.icon,
    required this.label,
    this.variant = EkemaTagVariant.defaultTag,
  });

  (Color bg, Color fg) get _colors => switch (variant) {
        EkemaTagVariant.cost => (EkemaColors.warningLight, EkemaColors.warning),
        EkemaTagVariant.time => (EkemaColors.brandLight, EkemaColors.brand),
        EkemaTagVariant.doc => (EkemaColors.infoLight, EkemaColors.info),
        EkemaTagVariant.defaultTag => (EkemaColors.subtle, EkemaColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(EkemaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: fg),
          ),
        ],
      ),
    );
  }
}
