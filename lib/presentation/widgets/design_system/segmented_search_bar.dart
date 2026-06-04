import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Airbnb-style segmented search bar (3 zones).
class SegmentedSearchBar extends StatelessWidget {
  final VoidCallback? onTap;
  final VoidCallback? onVoiceTap;

  const SegmentedSearchBar({
    super.key,
    this.onTap,
    this.onVoiceTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(CivioRadius.lg),
      color: CivioColors.canvas,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CivioRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: CivioSpacing.lg, horizontal: CivioSpacing.xl),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _segment('Démarche', 'CNI, bourse, concours…'),
                    const Divider(height: CivioSpacing.xl),
                    Row(
                      children: [
                        Expanded(child: _segment('Ville', 'Yaoundé')),
                        Container(width: 1, height: 32, color: CivioColors.border),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: CivioSpacing.lg),
                            child: _segment('Mode', 'Voix ou texte'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CivioSpacing.md),
              Material(
                color: CivioColors.brand,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: onVoiceTap,
                  borderRadius: BorderRadius.circular(16),
                  child: const SizedBox(
                    width: 52,
                    height: 52,
                    child: Icon(Icons.search, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _segment(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: CivioColors.textPrimary,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 13, color: CivioColors.textSecondary),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
