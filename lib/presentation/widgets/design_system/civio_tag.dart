import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum CivioTagVariant { cost, time, doc, defaultTag }

class CivioTag extends StatelessWidget {
  final IconData icon;
  final String label;
  final CivioTagVariant variant;

  const CivioTag({
    super.key,
    required this.icon,
    required this.label,
    this.variant = CivioTagVariant.defaultTag,
  });

  (Color bg, Color fg) get _colors => switch (variant) {
        CivioTagVariant.cost => (CivioColors.warningLight, CivioColors.warning),
        CivioTagVariant.time => (CivioColors.brandLight, CivioColors.brand),
        CivioTagVariant.doc => (CivioColors.infoLight, CivioColors.info),
        CivioTagVariant.defaultTag => (CivioColors.subtle, CivioColors.textSecondary),
      };

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = _colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(CivioRadius.pill),
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
