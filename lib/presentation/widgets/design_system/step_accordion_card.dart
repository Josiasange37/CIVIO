import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'civio_tag.dart';

class StepAccordionCard extends StatelessWidget {
  final int index;
  final String title;
  final String description;
  final String cost;
  final String time;
  final bool isExpanded;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback? onToggleComplete;

  const StepAccordionCard({
    super.key,
    required this.index,
    required this.title,
    required this.description,
    required this.cost,
    required this.time,
    required this.isExpanded,
    required this.isCompleted,
    required this.onTap,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: CivioSpacing.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: CivioColors.canvas,
          borderRadius: BorderRadius.circular(CivioRadius.lg),
          boxShadow: CivioShadows.md,
          border: Border.all(
            color: isCompleted ? CivioColors.brand : Colors.transparent,
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(CivioRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(CivioSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isCompleted
                                ? [CivioColors.brand, CivioColors.brandHover]
                                : [CivioColors.brandLight, CivioColors.brandLight],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: onToggleComplete,
                            borderRadius: BorderRadius.circular(12),
                            child: Center(
                              child: isCompleted
                                  ? const Icon(Icons.check_rounded, color: Colors.white, size: 22)
                                  : Text(
                                      '$index',
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w800,
                                        color: CivioColors.brand,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: CivioSpacing.lg),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: CivioColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: CivioColors.textSecondary,
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: CivioSpacing.lg),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: CivioColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: CivioSpacing.lg),
                    Wrap(
                      spacing: CivioSpacing.sm,
                      runSpacing: CivioSpacing.sm,
                      children: [
                        if (cost != '0 FCFA')
                          CivioTag(icon: Icons.payments_outlined, label: cost, variant: CivioTagVariant.cost),
                        CivioTag(icon: Icons.schedule, label: time, variant: CivioTagVariant.time),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
