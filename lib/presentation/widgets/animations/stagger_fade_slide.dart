import 'package:flutter/material.dart';

class StaggerFadeSlide extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration delay;
  final Duration duration;

  const StaggerFadeSlide({
    super.key,
    required this.child,
    required this.index,
    this.delay = const Duration(milliseconds: 70),
    this.duration = const Duration(milliseconds: 450),
  });

  @override
  State<StaggerFadeSlide> createState() => _StaggerFadeSlideState();
}

class _StaggerFadeSlideState extends State<StaggerFadeSlide> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: widget.duration);
    _slide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(parent: _c, curve: Curves.elasticOut),
    );
    _fade = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    Future.delayed(widget.delay * widget.index, () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
