import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'ekema_tag.dart';

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
      padding: const EdgeInsets.only(bottom: EkemaSpacing.md),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: EkemaColors.canvas,
          borderRadius: BorderRadius.circular(EkemaRadius.lg),
          boxShadow: EkemaShadows.md,
          border: Border.all(
            color: isCompleted ? EkemaColors.brand : Colors.transparent,
            width: 2,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(EkemaRadius.lg),
            child: Padding(
              padding: const EdgeInsets.all(EkemaSpacing.xl),
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
                                ? [EkemaColors.brand, EkemaColors.brandHover]
                                : [EkemaColors.brandLight, EkemaColors.brandLight],
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
                                        color: EkemaColors.brand,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: EkemaSpacing.lg),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: EkemaColors.textPrimary,
                          ),
                        ),
                      ),
                      Icon(
                        isExpanded ? Icons.expand_less : Icons.expand_more,
                        color: EkemaColors.textSecondary,
                      ),
                    ],
                  ),
                  if (isExpanded) ...[
                    const SizedBox(height: EkemaSpacing.lg),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.55,
                        color: EkemaColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: EkemaSpacing.lg),
                    Wrap(
                      spacing: EkemaSpacing.sm,
                      runSpacing: EkemaSpacing.sm,
                      children: [
                        if (cost != '0 FCFA')
                          EkemaTag(icon: Icons.payments_outlined, label: cost, variant: EkemaTagVariant.cost),
                        EkemaTag(icon: Icons.schedule, label: time, variant: EkemaTagVariant.time),
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
