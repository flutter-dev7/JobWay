// features/candidate_profile/presentation/pages/candidate_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobway_app/core/utils/image_utils.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_photo.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/skill_chip.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/candidate_profile_provider.dart';
import 'edit_candidate_profile_page.dart';

class CandidateProfilePage extends ConsumerStatefulWidget {
  const CandidateProfilePage({super.key});

  @override
  ConsumerState<CandidateProfilePage> createState() =>
      _CandidateProfilePageState();
}

class _CandidateProfilePageState extends ConsumerState<CandidateProfilePage> {
  bool _isUploadingPhoto = false;

  String _experienceLevelLabel(String level) {
    switch (level) {
      case 'NoExperience':
        return 'Без опыта';
      case 'Junior':
        return 'Junior';
      case 'Middle':
        return 'Middle';
      case 'Senior':
        return 'Senior';
      default:
        return level;
    }
  }

  String _employmentTypeLabel(String type) {
    switch (type) {
      case 'FullTime':
        return 'Полная занятость';
      case 'PartTime':
        return 'Частичная занятость';
      case 'Remote':
        return 'Удалённо';
      case 'Internship':
        return 'Стажировка';
      default:
        return type;
    }
  }

  Future<void> _openResume(String resumeFileUrl) async {
    final uri = Uri.parse('${ApiConstants.fileBaseUrl}$resumeFileUrl');
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

  Future<void> _logout() async {
    final confirmed = await confirmLogoutDialog(context);
    if (!confirmed) return;

    await ref.read(authRepositoryProvider).logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(candidateProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Мой профиль',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: const Icon(
              Icons.logout_rounded,
              size: 20,
              color: Color(0xFFDC2626),
            ),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(
                Icons.edit_outlined,
                size: 21,
                color: Color(0xFF111827),
              ),
              onPressed: () async {
                final profile = profileAsync.valueOrNull;
                if (profile == null) return;

                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => EditCandidateProfilePage(profile: profile),
                  ),
                );
                ref.invalidate(candidateProfileProvider);
              },
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ApiException.extractMessage(error),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.035),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ProfilePhoto(
                    photoUrl:
                        profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                        ? '${ApiConstants.fileBaseUrl}${profile.photoUrl}'
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
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                  if (profile.location != null &&
                      profile.location!.isNotEmpty) ...[
                    const SizedBox(height: 7),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF9CA3AF),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          profile.location!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF6B7280),
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
                                    '${profile.fullName} — профиль на JobWay\n${_experienceLevelLabel(profile.experienceLevel)} · ${profile.location ?? ""}',
                              ),
                            );
                          },
                          icon: const Icon(Icons.ios_share_rounded, size: 16),
                          label: const Text('Поделиться'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFF111827),
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
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
                            backgroundColor: const Color(0xFF111827),
                            disabledBackgroundColor: const Color(
                              0xFF111827,
                            ).withOpacity(0.3),
                            foregroundColor: Colors.white,
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
                  _InfoRow(
                    icon: Icons.trending_up_rounded,
                    label: 'Уровень опыта',
                    value: _experienceLevelLabel(profile.experienceLevel),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.work_outline_rounded,
                    label: 'Тип занятости',
                    value: _employmentTypeLabel(profile.desiredEmploymentType),
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
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SectionCard(
              title: 'Навыки',
              icon: Icons.auto_awesome_outlined,
              child: profile.skills.isEmpty
                  ? const Text(
                      'Навыки пока не добавлены',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
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
                  ? const Text(
                      'Резюме не загружено — добавьте его в редактировании профиля',
                      style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)),
                    )
                  : GestureDetector(
                      onTap: () => _openResume(profile.resumeFileUrl!),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9FAFB),
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
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF111827),
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 18,
                              color: Color(0xFF9CA3AF),
                            ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 19, color: const Color(0xFF6B7280)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF)),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
