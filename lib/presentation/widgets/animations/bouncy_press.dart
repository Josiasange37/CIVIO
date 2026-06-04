import 'package:flutter/material.dart';

/// Duolingo-style press: squish down then spring back.
class BouncyPress extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double shrinkScale;

  const BouncyPress({
    super.key,
    required this.child,
    this.onTap,
    this.shrinkScale = 0.94,
  });

  @override
  State<BouncyPress> createState() => _BouncyPressState();
}

class _BouncyPressState extends State<BouncyPress> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scale = Tween<double>(begin: 1, end: widget.shrinkScale).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Future<void> _onTap() async {
    if (widget.onTap == null) return;
    await _c.forward();
    await _c.reverse();
    widget.onTap!();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _onTap,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
