import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class DuoProgressBar extends StatefulWidget {
  final double value; // 0..1
  final String label;
  final Color color;

  const DuoProgressBar({
    super.key,
    required this.value,
    this.label = '',
    this.color = const Color(0xFF58CC02),
  });

  @override
  State<DuoProgressBar> createState() => _DuoProgressBarState();
}

class _DuoProgressBarState extends State<DuoProgressBar> with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 600))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: CivioColors.textSecondary),
            ),
          ),
        Stack(
          children: [
            Container(
              height: 18,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xFFE5E5E5),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.elasticOut,
                  height: 18,
                  width: constraints.maxWidth * widget.value.clamp(0.05, 1.0),
                  decoration: BoxDecoration(
                    color: widget.color,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: widget.color.withValues(alpha: 0.35), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                );
              },
            ),
            if (widget.value > 0.05)
              Positioned(
                right: 8,
                top: 2,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.9, end: 1.1).animate(_pulse),
                  child: const Icon(Icons.bolt, color: Colors.white, size: 14),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class DuoXpToast extends StatefulWidget {
  final int xp;
  final VoidCallback? onDone;

  const DuoXpToast({super.key, required this.xp, this.onDone});

  @override
  State<DuoXpToast> createState() => _DuoXpToastState();
}

class _DuoXpToastState extends State<DuoXpToast> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _scale = CurvedAnimation(parent: _c, curve: Curves.elasticOut);
    _c.forward().then((_) => Future.delayed(const Duration(milliseconds: 1200), () {
          if (mounted) widget.onDone?.call();
        }));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF58CC02),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF46A302), width: 3),
          boxShadow: [
            BoxShadow(color: const Color(0xFF46A302).withValues(alpha: 0.4), blurRadius: 0, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.star_rounded, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            Text(
              '+${widget.xp} XP',
              style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}
