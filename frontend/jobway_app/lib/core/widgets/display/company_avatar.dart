import 'package:flutter/material.dart';
import 'package:jobway_app/core/constants/api_constants.dart';

class CompanyAvatar extends StatelessWidget {
  final String companyName;
  final double size;
  final String? logoUrl;

  const CompanyAvatar({
    super.key,
    required this.companyName,
    this.size = 44,
    this.logoUrl,
  });

  static const List<Color> _lightPalette = [
    Color(0xFFDCE5FF),
    Color(0xFFFFE4E6),
    Color(0xFFDCFCE7),
    Color(0xFFFEF3C7),
    Color(0xFFE0E7FF),
    Color(0xFFDDF4FF),
  ];

  static const List<Color> _darkPalette = [
    Color(0xFF2A3563),
    Color(0xFF4A2530),
    Color(0xFF1E3A2E),
    Color(0xFF4A3A1E),
    Color(0xFF2E2A52),
    Color(0xFF1E3A45),
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
    return hash % _lightPalette.length;
  }

  String _initials() {
    final words = companyName.trim().split(RegExp(r'\s+'));
    if (words.isEmpty || words.first.isEmpty) return '?';
    if (words.length == 1) return words.first.substring(0, 1).toUpperCase();
    return (words[0].substring(0, 1) + words[1].substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.28),
        child: Image.network(
          ApiConstants.resolveFileUrl(logoUrl!),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildInitials(context),
        ),
      );
    }
    return _buildInitials(context);
  }

  Widget _buildInitials(BuildContext context) {
    final index = _colorIndex();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark ? _darkPalette[index] : _lightPalette[index];

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Center(
        child: Text(
          _initials(),
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w700,
            color: _textPalette[index],
          ),
        ),
      ),
    );
  }
}
