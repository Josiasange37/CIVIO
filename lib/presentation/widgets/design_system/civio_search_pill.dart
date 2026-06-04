import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CivioSearchPill extends StatelessWidget {
  final ValueChanged<String>? onSearch;
  final VoidCallback? onVoiceTap;

  const CivioSearchPill({
    super.key,
    this.onSearch,
    this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CivioColors.canvas,
        borderRadius: BorderRadius.circular(CivioRadius.lg),
        boxShadow: CivioShadows.md,
        border: Border.all(color: CivioColors.border.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: CivioSpacing.lg, vertical: CivioSpacing.sm),
      child: Row(
        children: [
          const Icon(Icons.search, size: 22, color: CivioColors.textSecondary),
          const SizedBox(width: CivioSpacing.md),
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
                      color: CivioColors.textSecondary,
                    ),
              ),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Material(
            color: CivioColors.brand,
            shape: const CircleBorder(),
            elevation: 2,
            shadowColor: CivioColors.brand.withValues(alpha: 0.4),
            child: InkWell(
              onTap: onVoiceTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(Icons.mic, color: CivioColors.textInverse, size: 22),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
