import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Vertical Airbnb-style listing card with large visual header.
class ProcedureListingCard extends StatelessWidget {
  final String title;
  final String location;
  final String duration;
  final String cost;
  final List<Color> headerGradient;
  final IconData icon;
  final double width;
  final VoidCallback? onTap;

  const ProcedureListingCard({
    super.key,
    required this.title,
    required this.location,
    required this.duration,
    required this.cost,
    required this.headerGradient,
    required this.icon,
    this.width = 260,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 168,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(CivioRadius.lg),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: headerGradient,
                ),
                boxShadow: CivioShadows.md,
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: Icon(icon, size: 56, color: Colors.white.withValues(alpha: 0.35)),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(CivioRadius.pill),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.offline_bolt, size: 14, color: CivioColors.success),
                          SizedBox(width: 4),
                          Text(
                            'Hors ligne',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: CivioColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CivioSpacing.md),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: CivioColors.textPrimary,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.place_outlined, size: 14, color: CivioColors.textSecondary),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    location,
                    style: const TextStyle(fontSize: 13, color: CivioColors.textSecondary),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: CivioSpacing.sm),
            Row(
              children: [
                _metaChip(Icons.schedule, duration),
                const SizedBox(width: CivioSpacing.sm),
                _metaChip(Icons.payments_outlined, cost),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: CivioColors.subtle,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: CivioColors.textSecondary),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CivioColors.textSecondary)),
        ],
      ),
    );
  }
}
