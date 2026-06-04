import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// Civio mascot — Duolingo-style bouncing guide character.
class DuoMascot extends StatefulWidget {
  final double size;
  final String? mood; // happy, thinking, celebrate

  const DuoMascot({super.key, this.size = 72, this.mood = 'happy'});

  @override
  State<DuoMascot> createState() => _DuoMascotState();
}

class _DuoMascotState extends State<DuoMascot> with SingleTickerProviderStateMixin {
  late AnimationController _bounce;

  @override
  void initState() {
    super.initState();
    _bounce = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  Color get _bodyColor => switch (widget.mood) {
        'celebrate' => const Color(0xFF58CC02),
        'thinking' => const Color(0xFF1CB0F6),
        _ => CivioColors.brand,
      };

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _bounce,
      builder: (context, child) {
        final dy = widget.mood == 'celebrate' ? -8 * _bounce.value : -4 * _bounce.value;
        return Transform.translate(offset: Offset(0, dy), child: child);
      },
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: widget.size,
              height: widget.size * 0.88,
              decoration: BoxDecoration(
                color: _bodyColor,
                borderRadius: BorderRadius.circular(widget.size * 0.35),
                boxShadow: [
                  BoxShadow(
                    color: _bodyColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
            ),
            Positioned(
              top: widget.size * 0.22,
              left: widget.size * 0.22,
              child: _eye(),
            ),
            Positioned(
              top: widget.size * 0.22,
              right: widget.size * 0.22,
              child: _eye(),
            ),
            Positioned(
              bottom: widget.size * 0.28,
              child: Container(
                width: widget.size * 0.35,
                height: widget.size * 0.12,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            if (widget.mood == 'celebrate')
              Positioned(
                top: 0,
                right: 0,
                child: Icon(Icons.star_rounded, color: Colors.amber.shade400, size: widget.size * 0.28),
              ),
          ],
        ),
      ),
    );
  }

  Widget _eye() {
    return Container(
      width: widget.size * 0.14,
      height: widget.size * 0.18,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          width: widget.size * 0.08,
          height: widget.size * 0.08,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: const BoxDecoration(color: Color(0xFF222222), shape: BoxShape.circle),
        ),
      ),
    );
  }
}

class MascotSpeechBubble extends StatelessWidget {
  final String text;
  final DuoMascot mascot;

  const MascotSpeechBubble({
    super.key,
    required this.text,
    this.mascot = const DuoMascot(size: 64),
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        mascot,
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
              border: Border.all(color: const Color(0xFFE5E5E5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16, height: 1.45, fontWeight: FontWeight.w600, color: Color(0xFF222222)),
            ),
          ),
        ),
      ],
    );
  }
}
