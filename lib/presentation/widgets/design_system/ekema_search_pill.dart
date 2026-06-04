import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class EkemaSearchPill extends StatelessWidget {
  final ValueChanged<String>? onSearch;
  final VoidCallback? onVoiceTap;

  const EkemaSearchPill({
    super.key,
    this.onSearch,
    this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: EkemaColors.canvas,
        borderRadius: BorderRadius.circular(EkemaRadius.lg),
        boxShadow: EkemaShadows.md,
        border: Border.all(color: EkemaColors.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: EkemaSpacing.lg, vertical: EkemaSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22, color: EkemaColors.textSecondary),
          const SizedBox(width: EkemaSpacing.md),
          Expanded(
            child: TextField(
              onChanged: onSearch,
              decoration: InputDecoration(
                hintText: 'Décrivez votre situation…',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                fillColor: Colors.transparent,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: EkemaColors.textSecondary,
                    ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Material(
            color: EkemaColors.brand,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: EkemaColors.brand.withValues(alpha: 0.4),
            child: InkWell(
              onTap: onVoiceTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.mic, color: EkemaColors.textInverse, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
