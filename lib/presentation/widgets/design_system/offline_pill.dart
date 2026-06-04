import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class OfflinePill extends StatelessWidget {
  final String title;
  final String message;

  const OfflinePill({
    super.key,
    this.title = 'Mode hors ligne',
    this.message =
        'Civio fonctionne avec ou sans connexion. Les procédures de base restent toujours accessibles.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(EkemaSpacing.lg),
      decoration: BoxDecoration(
        color: EkemaColors.successLight,
        borderRadius: BorderRadius.circular(EkemaRadius.md),
        border: Border.all(color: EkemaColors.success.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi_off_rounded, size: 18, color: EkemaColors.success),
              const SizedBox(width: EkemaSpacing.sm),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: EkemaColors.success,
                      fontSize: 14,
                    ),
              ),
            ],
          ),
          const SizedBox(height: EkemaSpacing.sm),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: EkemaColors.textPrimary.withValues(alpha: 0.75),
                  fontSize: 13,
                ),
          ),
        ],
      ),
    );
  }
}
