import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ListingRow extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;

  const ListingRow({
    super.key,
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: EkemaColors.canvas,
      borderRadius: BorderRadius.circular(EkemaRadius.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(EkemaRadius.md),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(EkemaRadius.md),
            boxShadow: EkemaShadows.sm,
          ),
          child: Padding(
            padding: const EdgeInsets.all(EkemaSpacing.lg),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(EkemaRadius.sm),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: EkemaSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 15),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: EkemaColors.textSecondary,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: EkemaColors.textSecondary, size: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
