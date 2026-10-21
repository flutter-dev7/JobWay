import 'package:flutter/material.dart';

class VacancyTopStyle {
  static const amber = Color(0xFFF59E0B);
  static const amberDeep = Color(0xFFD97706);
}

// Общие размеры карточек вакансии (в ленте и в «Моих вакансиях»), чтобы они совпадали
class VacancyCardLayout {
  static const padding = 20.0;
  static const gap = 16.0;
  static const headerHeight = 44.0;
  static const tagsHeight = 30.0;
  static const bottomHeight = 40.0;
}

// Янтарная лента сверху карточки продвигаемой вакансии
class VacancyTopRibbon extends StatelessWidget {
  final String title;
  final String? trailing;

  const VacancyTopRibbon({super.key, required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [VacancyTopStyle.amber, VacancyTopStyle.amberDeep],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_rounded, size: 15, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          if (trailing != null)
            Text(
              trailing!,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
        ],
      ),
    );
  }
}
