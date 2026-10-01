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

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxBarWidth = screenWidth - 48;
    final itemSize = (maxBarWidth / items.length).clamp(40.0, 52.0);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.3 : 0.08,
            ),
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
              width: itemSize,
              height: itemSize,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: BoxDecoration(
                color: selected ? colors.surfaceMuted : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                items[index].icon,
                size: 21,
                color: colors.textPrimary,
              ),
            ),
          );
        }),
      ),
    ); 
  }
}
