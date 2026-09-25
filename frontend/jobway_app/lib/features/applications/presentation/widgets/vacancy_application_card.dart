// features/applications/presentation/widgets/vacancy_application_card.dart — заменить целиком
import 'package:flutter/material.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/widgets/skill_chip.dart';
import '../../../candidate_profile/presentation/pages/candidate_profile_view_page.dart';
import '../../domain/entities/job_application.dart';

class VacancyApplicationCard extends StatelessWidget {
  final JobApplication application;
  final ValueChanged<String> onStatusChanged;
  final bool isUpdating;
  final bool isLocked;

  const VacancyApplicationCard({
    super.key,
    required this.application,
    required this.onStatusChanged,
    this.isUpdating = false,
    this.isLocked = false,
  });

  static const _statuses = ['Pending', 'Viewed', 'Interview', 'Accepted', 'Rejected'];

  String _statusLabel(String status) => switch (status) {
        'Pending' => 'На рассмотрении',
        'Viewed' => 'Просмотрено',
        'Interview' => 'Собеседование',
        'Accepted' => 'Принято',
        'Rejected' => 'Отклонено',
        _ => status,
      };

  Color _statusColor(String status) => switch (status) {
        'Accepted' => const Color(0xFF059669),
        'Rejected' => const Color(0xFFDC2626),
        'Interview' => const Color(0xFF3157D5),
        'Viewed' => const Color(0xFFD97706),
        _ => const Color(0xFF6B7280),
      };

  @override
  Widget build(BuildContext context) {
    final hasPhoto = application.candidatePhotoUrl != null && application.candidatePhotoUrl!.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CandidateProfileViewPage(candidateProfileId: application.candidateProfileId)),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F5FF),
                    shape: BoxShape.circle,
                    image: hasPhoto
                        ? DecorationImage(image: NetworkImage('${ApiConstants.fileBaseUrl}${application.candidatePhotoUrl}'), fit: BoxFit.cover)
                        : null,
                  ),
                  child: !hasPhoto
                      ? Center(
                          child: Text(
                            application.candidateFullName.trim().isNotEmpty ? application.candidateFullName.trim()[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF3157D5)),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(application.candidateFullName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFF9CA3AF)),
                    ],
                  ),
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(color: Color(0xFFF3F5FF), shape: BoxShape.circle),
                  child: Center(
                    child: Text('${application.matchScore}%',
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF3157D5))),
                  ),
                ),
              ],
            ),
          ),
          if (application.coverMessage != null && application.coverMessage!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10)),
              child: Text(application.coverMessage!,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)), maxLines: 3, overflow: TextOverflow.ellipsis),
            ),
          ],
          if (application.matchedSkills.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(spacing: 6, runSpacing: 6, children: application.matchedSkills.map((s) => SkillChip(label: s.nameRu)).toList()),
          ],
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            value: application.status,
            items: _statuses
                .map((s) => DropdownMenuItem(
                      value: s,
                      child: Text(_statusLabel(s), style: TextStyle(color: _statusColor(s), fontWeight: FontWeight.w600)),
                    ))
                .toList(),
            onChanged: (isLocked || isUpdating)
                ? null
                : (value) {
                    if (value == null || value == application.status) return;
                    onStatusChanged(value);
                  },
            decoration: InputDecoration(
              filled: true,
              fillColor: isLocked ? const Color(0xFFF3F4F6) : const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
          if (isLocked) ...[
            const SizedBox(height: 6),
            const Text('Вакансия закрыта — статус нельзя изменить', style: TextStyle(fontSize: 11, color: Color(0xFF9CA3AF))),
          ],
        ],
      ),
    );
  }
}