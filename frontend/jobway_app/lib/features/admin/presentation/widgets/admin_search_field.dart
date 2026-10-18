import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';

class AdminSearchField extends StatefulWidget {
  final String hint;
  final ValueChanged<String> onChanged;

  const AdminSearchField({super.key, required this.hint, required this.onChanged});

  @override
  State<AdminSearchField> createState() => _AdminSearchFieldState();
}

class _AdminSearchFieldState extends State<AdminSearchField> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    // Запрос уходит через 400 мс после последней введённой буквы
    _debounce = Timer(
      const Duration(milliseconds: 400),
      () => widget.onChanged(value.trim()),
    );
  }

  void _clear() {
    _controller.clear();
    _debounce?.cancel();
    setState(() {});
    widget.onChanged('');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        style: TextStyle(color: colors.textPrimary),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(color: colors.textMuted),
          prefixIcon: Icon(Icons.search, color: colors.textMuted),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, size: 18, color: colors.textMuted),
                  onPressed: _clear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}