import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import 'package:jobway_app/core/widgets/buttons/app_button.dart';
import 'package:jobway_app/core/widgets/display/info_row.dart';
import 'package:jobway_app/core/widgets/feedback/app_snackbar.dart';
import 'package:jobway_app/core/widgets/navigation/app_page_app_bar.dart';
import 'package:jobway_app/features/invitations/presentation/widgets/invite_candidate_sheet.dart';
import 'package:jobway_app/features/review/presentation/widgets/reviews_section.dart';
import 'package:jobway_app/features/subscription/presentation/providers/subscription_provider.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/display/skill_chip.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/candidate_profile_provider.dart';

class CandidateProfileViewPage extends ConsumerWidget {
  final String candidateProfileId;

  const CandidateProfileViewPage({super.key, required this.candidateProfileId});

  Future<void> _openResume(BuildContext context, String resumeFileUrl) async {
    final uri = Uri.parse(ApiConstants.resolveFileUrl(resumeFileUrl));
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      AppSnackbar.showError('Не удалось открыть резюме');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(
      candidateProfileByIdProvider(candidateProfileId),
    );
    final colors = context.colors;
    final isEmployer = ref.watch(subscriptionProvider).valueOrNull != null;
    final loadedProfile = profileAsync.valueOrNull;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appMinimalAppBar(context),
            bottomNavigationBar: isEmployer && loadedProfile != null
          ? SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                decoration: BoxDecoration(
                  color: colors.background,
                  border: Border(top: BorderSide(color: colors.border)),
                ),
                child: AppButton(
                  label: 'Пригласить на вакансию',
                  icon: Icons.mail_outline_rounded,
                  onPressed: () => InviteCandidateSheet.show(
                    context,
                    candidateProfileId: candidateProfileId,
                    candidateName: loadedProfile.fullName,
                  ),
                ),
              ),
            )
          : null,
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ApiException.extractMessage(error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(
                      Theme.of(context).brightness == Brightness.dark
                          ? 0.2
                          : 0.035,
                    ),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.border, width: 3),
                      image:
                          profile.photoUrl != null &&
                              profile.photoUrl!.isNotEmpty
                          ? DecorationImage(
                              image: NetworkImage(
                                ApiConstants.resolveFileUrl(profile.photoUrl!),
                              ),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                        ? Center(
                            child: Text(
                              profile.fullName.trim().isNotEmpty
                                  ? profile.fullName.trim()[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w700,
                                color: context.accentColor,
                              ),
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    profile.fullName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (profile.location != null) ...[
                    const SizedBox(height: 7),
                    Text(
                      profile.location!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            SectionCard(
              title: 'Основная информация',
              icon: Icons.person_outline_rounded,
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.trending_up_rounded,
                    label: 'Уровень опыта',
                    value: experienceLevelLabel(profile.experienceLevel),
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: LucideIcons.briefcase,
                    label: 'Тип занятости',
                    value: employmentTypeLabel(profile.desiredEmploymentType),
                  ),
                ],
              ),
            ),
            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'О себе',
                icon: Icons.notes_rounded,
                child: Text(
                  profile.bio!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SectionCard(
              title: 'Навыки',
              icon: Icons.auto_awesome_outlined,
              child: profile.skills.isEmpty
                  ? Text(
                      'Не указаны',
                      style: TextStyle(fontSize: 14, color: colors.textMuted),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 10,
                      children: profile.skills
                          .map((s) => SkillChip(label: s.nameRu))
                          .toList(),
                    ),
            ),
            if (profile.resumeFileUrl != null &&
                profile.resumeFileUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'Резюме',
                icon: Icons.attach_file_rounded,
                child: GestureDetector(
                  onTap: () => _openResume(context, profile.resumeFileUrl!),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.picture_as_pdf_outlined,
                            size: 20,
                            color: Color(0xFFDC2626),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Открыть резюме',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colors.textPrimary,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.open_in_new_rounded,
                          size: 18,
                          color: colors.textMuted,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ReviewsSection(userId: profile.userId),
          ],
        ),
      ),
    );
  }
}
