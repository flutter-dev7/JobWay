import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class FloatingNavItem {
  final IconData icon;
  final String label;

  FloatingNavItem({required this.icon, required this.label});
}

class FloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<FloatingNavItem> items;

  const FloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  static const double _itemWidth = 64;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length, (index) {
          final selected = currentIndex == index;

          return GestureDetector(
            onTap: () => onTap(index),
            behavior: HitTestBehavior.opaque,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: _itemWidth,
              height: 48,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: selected ? colors.surfaceMuted : Colors.transparent,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Icon(items[index].icon, size: 24, color: colors.textPrimary),
            ),
          );
        }),
      ),
    );
  }
}