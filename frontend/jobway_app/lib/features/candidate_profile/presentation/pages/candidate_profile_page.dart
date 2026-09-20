import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/widgets/app_button.dart';
import 'package:jobway_app/core/widgets/app_snackbar.dart';
import 'package:jobway_app/core/widgets/skill_chip.dart';
import 'package:jobway_app/features/auth/presentation/pages/login_page.dart';
import 'package:jobway_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:jobway_app/features/candidate_profile/presentation/widgets/info_row.dart';
import 'package:jobway_app/features/candidate_profile/presentation/widgets/profile_header.dart';
import 'package:jobway_app/core/widgets/section_card.dart';
import '../../../../core/network/api_exception.dart';
import '../providers/candidate_profile_provider.dart';
import 'edit_candidate_profile_page.dart';

class CandidateProfilePage extends ConsumerWidget {
  const CandidateProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(candidateProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Мой профиль',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
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
                final profile = profileAsync.value;
                if (profile == null) return;

                try {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          EditCandidateProfilePage(profile: profile),
                    ),
                  );

                  ref.invalidate(candidateProfileProvider);
                } catch (error) {
                  AppSnackbar.showError(ApiException.extractMessage(error));
                }
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
            ProfileHeader(
              fullName: profile.fullName,
              location: profile.location,
            ),

            const SizedBox(height: 20),

            SectionCard(
              title: 'Основная информация',
              icon: Icons.person_outline_rounded,
              child: Column(
                children: [
                  InfoRow(
                    icon: Icons.trending_up_rounded,
                    label: 'Уровень опыта',
                    value: profile.experienceLevel,
                  ),
                  const SizedBox(height: 16),
                  InfoRow(
                    icon: Icons.work_outline_rounded,
                    label: 'Тип занятости',
                    value: profile.desiredEmploymentType,
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
                      children: profile.skills.map((skill) {
                        return SkillChip(label: skill.nameRu);
                      }).toList(),
                    ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Выйти',
              color: const Color(0xFFDC2626),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Выйти из аккаунта?'),
                    content: const Text(
                      'Придётся войти заново, чтобы продолжить пользоваться приложением',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Отмена'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Выйти'),
                      ),
                    ],
                  ),
                );

                if (confirmed != true) return;

                await ref.read(authRepositoryProvider).logout();
                if (!context.mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
