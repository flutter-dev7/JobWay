import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../../core/widgets/skill_chip.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/candidate_profile_provider.dart';

class CandidateProfileViewPage extends ConsumerWidget {
  final String candidateProfileId;

  const CandidateProfileViewPage({super.key, required this.candidateProfileId});

  String _experienceLevelLabel(String level) => switch (level) {
        'NoExperience' => 'Без опыта',
        'Junior' => 'Junior',
        'Middle' => 'Middle',
        'Senior' => 'Senior',
        _ => level,
      };

  String _employmentTypeLabel(String type) => switch (type) {
        'FullTime' => 'Полная занятость',
        'PartTime' => 'Частичная занятость',
        'Remote' => 'Удалённо',
        'Internship' => 'Стажировка',
        _ => type,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(candidateProfileByIdProvider(candidateProfileId));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(backgroundColor: const Color(0xFFF7F8FA), surfaceTintColor: Colors.transparent, elevation: 0),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(padding: const EdgeInsets.all(24), child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center)),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF3FF),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFDCE5FF), width: 3),
                      image: profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                          ? DecorationImage(image: NetworkImage('${ApiConstants.fileBaseUrl}${profile.photoUrl}'), fit: BoxFit.cover)
                          : null,
                    ),
                    child: profile.photoUrl == null || profile.photoUrl!.isEmpty
                        ? Center(
                            child: Text(profile.fullName.trim().isNotEmpty ? profile.fullName.trim()[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w700, color: Color(0xFF3157D5))),
                          )
                        : null,
                  ),
                  const SizedBox(height: 14),
                  Text(profile.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  if (profile.location != null) ...[
                    const SizedBox(height: 7),
                    Text(profile.location!, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
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
                  _InfoRow(icon: Icons.trending_up_rounded, label: 'Уровень опыта', value: _experienceLevelLabel(profile.experienceLevel)),
                  const SizedBox(height: 16),
                  _InfoRow(icon: Icons.work_outline_rounded, label: 'Тип занятости', value: _employmentTypeLabel(profile.desiredEmploymentType)),
                ],
              ),
            ),
            if (profile.bio != null && profile.bio!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'О себе',
                icon: Icons.notes_rounded,
                child: Text(profile.bio!, style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF4B5563))),
              ),
            ],
            const SizedBox(height: 16),
            SectionCard(
              title: 'Навыки',
              icon: Icons.auto_awesome_outlined,
              child: profile.skills.isEmpty
                  ? const Text('Не указаны', style: TextStyle(fontSize: 14, color: Color(0xFF9CA3AF)))
                  : Wrap(spacing: 8, runSpacing: 10, children: profile.skills.map((s) => SkillChip(label: s.nameRu)).toList()),
            ),
            if (profile.resumeFileUrl != null && profile.resumeFileUrl!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'Резюме',
                icon: Icons.attach_file_rounded,
                child: GestureDetector(
                  onTap: () => launchUrl(Uri.parse('${ApiConstants.fileBaseUrl}${profile.resumeFileUrl}'), mode: LaunchMode.externalApplication),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: const Color(0xFFFEE2E2), borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.picture_as_pdf_outlined, size: 20, color: Color(0xFFDC2626)),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text('Открыть резюме', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
                        ),
                        const Icon(Icons.open_in_new_rounded, size: 18, color: Color(0xFF9CA3AF)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, size: 19, color: const Color(0xFF6B7280)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
              const SizedBox(height: 3),
              Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
            ],
          ),
        ),
      ],
    );
  }
}