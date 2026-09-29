import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/widgets/display/skill_chip.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../domain/entities/job_application.dart';

class VacancyApplicationCard extends StatelessWidget {
  final JobApplication application;
  final ValueChanged<String> onStatusChanged;
  final bool isUpdating;
  final bool isLocked;
  final VoidCallback? onLeaveReview;

  const VacancyApplicationCard({
    super.key,
    required this.application,
    required this.onStatusChanged,
    this.isUpdating = false,
    this.isLocked = false,
    this.onLeaveReview,
  });

  static const _statuses = [
    'Pending',
    'Viewed',
    'Interview',
    'Accepted',
    'Rejected',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasPhoto =
        application.candidatePhotoUrl != null &&
        application.candidatePhotoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.03,
            ),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.push(
              AppRoutes.candidate(application.candidateProfileId),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    shape: BoxShape.circle,
                    image: hasPhoto
                        ? DecorationImage(
                            image: NetworkImage(
                              '${ApiConstants.fileBaseUrl}${application.candidatePhotoUrl}',
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !hasPhoto
                      ? Center(
                          child: Text(
                            application.candidateFullName.trim().isNotEmpty
                                ? application.candidateFullName
                                      .trim()[0]
                                      .toUpperCase()
                                : '?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: context.accentColor,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          application.candidateFullName,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: colors.textMuted,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: colors.surfaceMuted,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${application.matchScore}%',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: context.accentColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (application.coverMessage != null &&
              application.coverMessage!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                application.coverMessage!,
                style: TextStyle(fontSize: 13, color: colors.textSecondary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
          if (application.matchedSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: application.matchedSkills
                  .map((s) => SkillChip(label: s.nameRu))
                  .toList(),
            ),
          ],
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: application.status,
            items: _statuses
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(
                      applicationStatusLabel(s),
                      style: TextStyle(
                        color: applicationStatusColor(s),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: (isLocked || isUpdating)
                ? null
                : (value) {
                    if (value == null || value == application.status) return;
                    onStatusChanged(value);
                  },
            decoration: InputDecoration(
              filled: true,
              fillColor: isLocked
                  ? colors.border.withOpacity(0.3)
                  : colors.surfaceMuted,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: colors.border),
              ),
            ),
          ),
          if (isLocked) ...[
            const SizedBox(height: 6),
            Text(
              'Вакансия закрыта — статус нельзя изменить',
              style: TextStyle(fontSize: 11, color: colors.textMuted),
            ),
          ],
          if ((application.status == 'Accepted' ||
                  application.status == 'Rejected') &&
              !application.hasReviewFromCurrentUser &&
              onLeaveReview != null) ...[
            const SizedBox(height: 10),
            AppButton(
              label: 'Оценить кандидата',
              color: const Color(0xFF3157D5),
              onPressed: onLeaveReview,
            ),
          ],
        ],
      ),
    );
  }
}
