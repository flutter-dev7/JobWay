import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';
import '../buttons/app_back_button.dart';

PreferredSizeWidget appMinimalAppBar(BuildContext context, {List<Widget>? actions, VoidCallback? onBack}) {
  return AppBar(
    backgroundColor: context.colors.background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leadingWidth: 60,
    leading: AppBackButton(onPressed: onBack),
    actions: actions,
  );
}

PreferredSizeWidget appPageAppBar(BuildContext context, String title, {List<Widget>? actions, VoidCallback? onBack}) {
  return AppBar(
    backgroundColor: context.colors.background,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leadingWidth: 60,
    leading: AppBackButton(onPressed: onBack),
    title: Text(
      title,
      style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: context.colors.textPrimary),
    ),
    centerTitle: false,
    actions: actions,
  );
}