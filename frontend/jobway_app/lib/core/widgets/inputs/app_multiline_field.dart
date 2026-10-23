import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class AppMultilineField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final int minLines;
  final int maxLines;
  final int? maxLength;
  final ValueChanged<String>? onChanged;

  const AppMultilineField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.minLines = 4,
    this.maxLines = 10,
    this.maxLength,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    OutlineInputBorder border(Color color, {double width = 1}) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: color, width: width),
    );

    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: maxLines,
      maxLength: maxLength,
      onChanged: onChanged,
      keyboardType: TextInputType.multiline,
      textCapitalization: TextCapitalization.sentences,
      style: TextStyle(fontSize: 14, height: 1.5, color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: true,
        labelStyle: TextStyle(color: colors.textMuted),
        hintStyle: TextStyle(color: colors.textMuted),
        counterStyle: TextStyle(fontSize: 11, color: colors.textMuted),
        filled: true,
        fillColor: colors.surfaceMuted,
        contentPadding: const EdgeInsets.all(14),
        border: border(colors.border),
        enabledBorder: border(colors.border),
        focusedBorder: border(context.accentColor, width: 1.5),
      ),
    );
  }
}