import 'package:flutter/material.dart';

class CompanyAvatar extends StatelessWidget {
  final String companyName;
  final double size;

  const CompanyAvatar({super.key, required this.companyName, this.size = 44});

  static const List<Color> _palette = [
    Color(0xFFDCE5FF), // индиго
    Color(0xFFFFE4E6), // розовый
    Color(0xFFDCFCE7), // зелёный
    Color(0xFFFEF3C7), // жёлтый
    Color(0xFFE0E7FF), // фиолетовый
    Color(0xFFDDF4FF), // голубой
  ];

  static const List<Color> _textPalette = [
    Color(0xFF3157D5),
    Color(0xFFE11D48),
    Color(0xFF059669),
    Color(0xFFD97706),
    Color(0xFF6366F1),
    Color(0xFF0891B2),
  ];

  int _colorIndex() {
    final hash = companyName.codeUnits.fold<int>(0, (sum, c) => sum + c);
    return hash % _palette.length;
  }

  String _initials() {
    final words = companyName.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final index = _colorIndex();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: _palette[index], borderRadius: BorderRadius.circular(size * 0.28)),
      child: Center(
        child: Text(
          _initials(),
          style: TextStyle(fontSize: size * 0.36, fontWeight: FontWeight.w700, color: _textPalette[index]),
        ),
      ),
    );
  }
}