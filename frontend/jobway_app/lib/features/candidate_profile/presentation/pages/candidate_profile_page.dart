import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/utils/enum_labels.dart';
import 'package:jobway_app/core/utils/image_utils.dart';
import 'package:jobway_app/features/review/presentation/widgets/reviews_section.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/feedback/app_dialogs.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/display/info_row.dart';
import '../../../../core/widgets/display/profile_photo.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/display/skill_chip.dart';
import '../providers/candidate_profile_provider.dart';

class CandidateProfilePage extends ConsumerStatefulWidget {
  const CandidateProfilePage({super.key});

  @override
  ConsumerState<CandidateProfilePage> createState() =>
      _CandidateProfilePageState();
}

class _CandidateProfilePageState extends ConsumerState<CandidateProfilePage> {
  bool _isUploadingPhoto = false;

  Future<void> _openResume(String resumeFileUrl) async {
    final uri = Uri.parse(ApiConstants.resolveFileUrl(resumeFileUrl));
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _changePhoto() async {
    final source = await pickImageSourceDialog(context);
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final file = await ImageUtils.ensureCompatibleFormat(File(picked.path));
      await ref.read(uploadCandidatePhotoUseCaseProvider).call(file);
      ref.invalidate(candidateProfileProvider);
      AppSnackbar.showSuccess('Фото обновлено');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(candidateProfileProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Мой профиль',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                Icons.settings_outlined,
                size: 21,
                color: colors.textPrimary,
              ),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                Icons.edit_outlined,
                size: 21,
                color: colors.textPrimary,
              ),
              onPressed: () async {
                final profile = profileAsync.valueOrNull;
                if (profile == null) return;

                await context.push(
                  AppRoutes.editCandidateProfile,
                  extra: profile,
                );
                ref.invalidate(candidateProfileProvider);
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(candidateProfileProvider.future),
        child: profileAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                ApiException.extractMessage(error),
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: colors.textSecondary),
              ),
            ),
          ),
          data: (profile) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
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
                    ProfilePhoto(
                      photoUrl:
                          profile.photoUrl != null &&
                              profile.photoUrl!.isNotEmpty
                          ? ApiConstants.resolveFileUrl(profile.photoUrl!)
                          : null,
                      fallbackText: profile.fullName.trim().isNotEmpty
                          ? profile.fullName.trim()[0].toUpperCase()
                          : '?',
                      onEdit: _changePhoto,
                      isUploading: _isUploadingPhoto,
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
                    if (profile.location != null &&
                        profile.location!.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 16,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            profile.location!,
                            style: TextStyle(
                              fontSize: 14,
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      '${profile.fullName} — профиль на JobWay\n${experienceLevelLabel(profile.experienceLevel)} · ${profile.location ?? ""}',
                                ),
                              );
                            },
                            icon: const Icon(Icons.ios_share_rounded, size: 16),
                            label: const Text('Поделиться'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: colors.textPrimary,
                              side: BorderSide(color: colors.border),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed:
                                profile.resumeFileUrl != null &&
                                    profile.resumeFileUrl!.isNotEmpty
                                ? () => _openResume(profile.resumeFileUrl!)
                                : null,
                            icon: const Icon(
                              Icons.description_outlined,
                              size: 16,
                            ),
                            label: const Text('Резюме'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colors.textPrimary,
                              disabledBackgroundColor: colors.textPrimary
                                  .withOpacity(0.3),
                              foregroundColor: colors.surface,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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
                      icon: Icons.work_outline_rounded,
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
                        'Навыки пока не добавлены',
                        style: TextStyle(fontSize: 14, color: colors.textMuted),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 10,
                        children: profile.skills
                            .map((skill) => SkillChip(label: skill.nameRu))
                            .toList(),
                      ),
              ),
              const SizedBox(height: 16),
              SectionCard(
                title: 'Резюме',
                icon: Icons.attach_file_rounded,
                child:
                    profile.resumeFileUrl == null ||
                        profile.resumeFileUrl!.isEmpty
                    ? Text(
                        'Резюме не загружено — добавьте его в редактировании профиля',
                        style: TextStyle(fontSize: 14, color: colors.textMuted),
                      )
                    : GestureDetector(
                        onTap: () => _openResume(profile.resumeFileUrl!),
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
                                  profile.resumeFileUrl!.split('/').last,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
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
              const SizedBox(height: 16),
              ReviewsSection(userId: profile.userId),
            ],
          ),
        ),
      ),
    );
  }
}
