import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData light() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBackground,
        colorScheme: const ColorScheme.light(
          primary: AppColors.accent,
          surface: AppColors.lightSurface,
          onSurface: AppColors.lightTextPrimary,
        ),
        fontFamily: 'System',
        textTheme: _textTheme(AppColors.lightTextPrimary, AppColors.lightTextSecondary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.lightBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      );

  static ThemeData dark() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBackground,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentDark,
          surface: AppColors.darkSurface,
          onSurface: AppColors.darkTextPrimary,
        ),
        fontFamily: 'System',
        textTheme: _textTheme(AppColors.darkTextPrimary, AppColors.darkTextSecondary),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.darkBackground,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
      );

  static TextTheme _textTheme(Color primary, Color secondary) => TextTheme(
        bodyMedium: TextStyle(color: primary),
        bodySmall: TextStyle(color: secondary),
      );
}