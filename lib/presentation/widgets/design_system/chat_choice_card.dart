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
      padding: const EdgeInsets.only(bottom: CivioSpacing.md),
      child: Material(
        color: CivioColors.canvas,
        borderRadius: BorderRadius.circular(CivioRadius.md),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CivioRadius.md),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(CivioRadius.md),
              border: Border.all(color: CivioColors.border),
              boxShadow: CivioShadows.sm,
            ),
            child: Padding(
              padding: const EdgeInsets.all(CivioSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: CivioColors.brandLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: CivioColors.brand, size: 24),
                  ),
                  const SizedBox(width: CivioSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: CivioColors.textPrimary,
                          ),
                        ),
                        if (subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            style: const TextStyle(fontSize: 13, color: CivioColors.textSecondary),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: CivioColors.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
