import 'package:flutter/material.dart';
import 'app_colors.dart';

class SemanticColors {
  final Color background;
  final Color surface;
  final Color surfaceMuted;
  final Color border;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;

  const SemanticColors({
    required this.background,
    required this.surface,
    required this.surfaceMuted,
    required this.border,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
  });

  static const light = SemanticColors(
    background: AppColors.lightBackground,
    surface: AppColors.lightSurface,
    surfaceMuted: AppColors.lightSurfaceMuted,
    border: AppColors.lightBorder,
    textPrimary: AppColors.lightTextPrimary,
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
  );

  static const dark = SemanticColors(
    background: AppColors.darkBackground,
    surface: AppColors.darkSurface,
    surfaceMuted: AppColors.darkSurfaceMuted,
    border: AppColors.darkBorder,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
  );
}

extension ThemeContext on BuildContext {
  SemanticColors get colors =>
      Theme.of(this).brightness == Brightness.dark ? SemanticColors.dark : SemanticColors.light;

  Color get accentColor =>
      Theme.of(this).brightness == Brightness.dark ? AppColors.accentDark : AppColors.accent;
}