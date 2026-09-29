import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';

class AnalyticsEmptyHint extends StatelessWidget {
  final String text;

  const AnalyticsEmptyHint(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(color: context.colors.textMuted, fontSize: 13),
    );
  }
}
