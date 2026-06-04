import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class ChatChoiceCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const ChatChoiceCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: EkemaSpacing.md),
      child: Material(
        color: EkemaColors.canvas,
        borderRadius: BorderRadius.circular(EkemaRadius.md),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(EkemaRadius.md),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(EkemaRadius.md),
              border: Border.all(color: EkemaColors.border),
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
                      color: EkemaColors.brandLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: EkemaColors.brand, size: 24),
                  ),
                  const SizedBox(width: EkemaSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: EkemaColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(fontSize: 13, color: EkemaColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: EkemaColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
