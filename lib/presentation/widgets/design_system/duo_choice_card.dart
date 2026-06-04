import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../animations/bouncy_press.dart';

/// Duolingo-style answer card — thick border, bounce, success flash.
class DuoChoiceCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;

  const DuoChoiceCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  State<DuoChoiceCard> createState() => _DuoChoiceCardState();
}

class _DuoChoiceCardState extends State<DuoChoiceCard> with SingleTickerProviderStateMixin {
  bool _selected = false;
  late AnimationController _success;

  @override
  void initState() {
    super.initState();
    _success = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _success.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    if (!widget.enabled || _selected) return;
    setState(() => _selected = true);
    await _success.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    widget.onTap();
  }

  Color get _borderColor {
    if (_selected) return const Color(0xFF58CC02);
    return const Color(0xFFE5E5E5);
  }

  Color get _bottomColor {
    if (_selected) return const Color(0xFF46A302);
    return const Color(0xFFD1D1D1);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: BouncyPress(
        onTap: _handleTap,
        child: AnimatedBuilder(
          animation: _success,
          builder: (context, child) {
            final lift = _selected ? -2.0 * (1 - _success.value) : 0.0;
            return Transform.translate(offset: Offset(0, lift), child: child);
          },
          child: Container(
            decoration: BoxDecoration(
              color: _selected ? const Color(0xFFD7FFB8) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderColor, width: 3),
              boxShadow: [
                BoxShadow(color: _bottomColor, blurRadius: 0, offset: const Offset(0, 4)),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _selected ? const Color(0xFF58CC02) : EkemaColors.brandLight,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      _selected ? Icons.check_rounded : widget.icon,
                      color: _selected ? Colors.white : EkemaColors.brand,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _selected ? const Color(0xFF2B7A0B) : EkemaColors.textPrimary,
                          ),
                        ),
                        if (widget.subtitle != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 13,
                              color: _selected ? const Color(0xFF4A7C23) : EkemaColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
