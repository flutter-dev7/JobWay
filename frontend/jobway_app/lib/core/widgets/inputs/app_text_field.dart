import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final TextInputType keyboardType;
  final IconData? icon;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.icon,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscure : false,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(fontSize: 15, color: colors.textPrimary),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(color: colors.textMuted),
        prefixIcon: widget.icon != null ? Icon(widget.icon, size: 20, color: colors.textMuted) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: colors.textMuted,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: colors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: colors.textPrimary, width: 1.4),
        ),
      ),
    );
  }
}