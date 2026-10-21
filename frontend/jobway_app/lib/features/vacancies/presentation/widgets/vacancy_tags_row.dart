import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../domain/entities/vacancy.dart';
import 'vacancy_top_ribbon.dart';

// Теги вакансии в одну строку фиксированной высоты, чтобы карточки были одного размера
class VacancyTagsRow extends StatelessWidget {
  final Vacancy vacancy;

  const VacancyTagsRow({super.key, required this.vacancy});

  @override
  Widget build(BuildContext context) {
    final tags = <Widget>[
      _Tag(
        icon: LucideIcons.briefcase,
        label: employmentTypeLabel(vacancy.employmentType),
      ),
      _Tag(
        icon: LucideIcons.trendingUp,
        label: experienceLevelLabel(vacancy.experienceLevel),
      ),
      if (vacancy.location != null && vacancy.location!.isNotEmpty)
        _Tag(icon: LucideIcons.mapPin, label: vacancy.location!),
    ];

    return SizedBox(
      height: VacancyCardLayout.tagsHeight,
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) => const LinearGradient(
          colors: [Colors.white, Colors.white, Colors.transparent],
          stops: [0, 0.92, 1],
        ).createShader(bounds),
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          itemCount: tags.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, index) => tags[index],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Tag({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      height: VacancyCardLayout.tagsHeight,
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: colors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: colors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(fontSize: 11, color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}
