import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/company_avatar.dart';
import '../../domain/entities/vacancy.dart';
import '../providers/vacancies_provider.dart';

class VacancyCard extends ConsumerWidget {
  final Vacancy vacancy;
  final VoidCallback onTap;

  const VacancyCard({super.key, required this.vacancy, required this.onTap});

  String _formatSalary() {
    if (vacancy.salaryFrom == null && vacancy.salaryTo == null) return '';
    if (vacancy.salaryFrom != null && vacancy.salaryTo != null) {
      return '${vacancy.salaryFrom!.toStringAsFixed(0)} – ${vacancy.salaryTo!.toStringAsFixed(0)} TJS';
    }
    if (vacancy.salaryFrom != null)
      return 'от ${vacancy.salaryFrom!.toStringAsFixed(0)} TJS';
    return 'до ${vacancy.salaryTo!.toStringAsFixed(0)} TJS';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedVacancyIdsProvider);
    final isSaved = savedIds.contains(vacancy.id);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CompanyAvatar(
                  companyName: vacancy.companyName,
                  logoUrl: vacancy.companyLogoUrl,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vacancy.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        vacancy.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    final notifier = ref.read(savedVacancyIdsProvider.notifier);
                    try {
                      if (isSaved) {
                        await ref
                            .read(unsaveVacancyUseCaseProvider)
                            .call(vacancy.id);
                        notifier.update(
                          (state) => {...state}..remove(vacancy.id),
                        );
                      } else {
                        await ref
                            .read(saveVacancyUseCaseProvider)
                            .call(vacancy.id);
                        notifier.update((state) => {...state, vacancy.id});
                      }
                      ref.invalidate(
                        savedVacanciesProvider,
                      ); 
                    } catch (error) {
                      AppSnackbar.showError(ApiException.extractMessage(error));
                    }
                  },
                  child: Icon(
                    isSaved
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    size: 22,
                    color: isSaved
                        ? const Color(0xFF3157D5)
                        : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _Tag(
                  icon: Icons.work_outline_rounded,
                  label: employmentTypeLabel(vacancy.employmentType),
                ),
                _Tag(
                  icon: Icons.trending_up_rounded,
                  label: experienceLevelLabel(vacancy.experienceLevel),
                ),
                if (vacancy.location != null)
                  _Tag(
                    icon: Icons.location_on_outlined,
                    label: vacancy.location!,
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (_formatSalary().isNotEmpty)
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Зарплата в месяц',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatSalary(),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3157D5),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  const Spacer(),
                Text(
                  TimeAgo.format(vacancy.createdAt),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ],
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F6FA),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: const Color(0xFF6B7280)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
