import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../../../core/utils/time_ago.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../../../core/widgets/display/skill_chip.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../domain/entities/job_application.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;
  final VoidCallback? onLeaveReview;

  const ApplicationCard({
    super.key,
    required this.application,
    this.onLeaveReview,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final statusColor = applicationStatusColor(application.status);

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CompanyAvatar(
                companyName: application.companyName,
                size: 44,
                logoUrl: application.companyLogoUrl,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.vacancyTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      application.companyName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: colors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${application.matchScore}%',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: context.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  applicationStatusLabel(application.status),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (application.matchedSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: application.matchedSkills
                  .take(4)
                  .map((s) => SkillChip(label: s.nameRu))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'Отправлено ${TimeAgo.format(application.createdAt)}',
              style: TextStyle(fontSize: 11, color: colors.textMuted),
            ),
          ),
          if ((application.status == 'Accepted' ||
                  application.status == 'Rejected') &&
              !application.hasReviewFromCurrentUser &&
              onLeaveReview != null) ...[
            const SizedBox(height: 10),
            AppButton(
              label: 'Оценить компанию',
              color: const Color(0xFF3157D5),
              onPressed: onLeaveReview,
            ),
          ],
        ],
      ),
    );
  }
}
