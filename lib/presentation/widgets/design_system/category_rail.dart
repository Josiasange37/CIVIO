import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CategoryItem {
  final IconData icon;
  final String label;
  final Color background;
  final Color iconColor;
  final VoidCallback? onTap;

  const CategoryItem({
    required this.icon,
    required this.label,
    required this.background,
    required this.iconColor,
    this.onTap,
  });
}

class CategoryRail extends StatelessWidget {
  final List<CategoryItem> items;

  const CategoryRail({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: CivioSpacing.md),
        itemBuilder: (context, index) => _CategoryTile(item: items[index]),
      ),
    );
  }
}

class _CategoryTile extends StatefulWidget {
  final CategoryItem item;

  const _CategoryTile({required this.item});

  @override
  State<_CategoryTile> createState() => _CategoryTileState();
}

class _CategoryTileState extends State<_CategoryTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.item.onTap != null;
    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
      onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
      onTap: widget.item.onTap,
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 88,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: widget.item.background,
                  borderRadius: BorderRadius.circular(CivioRadius.md),
                  boxShadow: enabled ? CivioShadows.sm : null,
                ),
                child: Icon(widget.item.icon, color: widget.item.iconColor, size: 28),
              ),
              const SizedBox(height: CivioSpacing.sm),
              Text(
                widget.item.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: enabled ? CivioColors.textPrimary : CivioColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
