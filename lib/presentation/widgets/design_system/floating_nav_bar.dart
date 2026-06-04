import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  static const _items = [
    (Icons.home_rounded, 'Accueil'),
    (Icons.forum_outlined, 'Chat IA'),
    (Icons.map_outlined, 'Carte'),
    (Icons.edit_document, 'Rédiger'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: CivioColors.textPrimary,
          borderRadius: BorderRadius.circular(CivioRadius.pill),
          boxShadow: CivioShadows.lg,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(_items.length, (index) {
            final active = index == currentIndex;
            final item = _items[index];
            return Expanded(
              child: GestureDetector(
                onTap: () => onTap?.call(index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                  decoration: BoxDecoration(
                    color: active ? CivioColors.brand : Colors.transparent,
                    borderRadius: BorderRadius.circular(CivioRadius.pill),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item.$1,
                        size: 22,
                        color: active ? Colors.white : Colors.white54,
                      ),
                      if (active) ...[
                        const SizedBox(height: 2),
                        Text(
                          item.$2,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
