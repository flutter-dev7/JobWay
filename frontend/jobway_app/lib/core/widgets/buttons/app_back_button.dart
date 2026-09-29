import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme_extension.dart';

class AppBackButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const AppBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(left: 20),
        child: GestureDetector(
          onTap: onPressed ?? () => context.pop(),
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 15,
              color: colors.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
