import 'package:flutter/material.dart';
import '../../../../core/widgets/skill_chip.dart';
import '../../domain/entities/job_application.dart';

class VacancyApplicationCard extends StatelessWidget {
  final JobApplication application;
  final ValueChanged<String> onStatusChanged;
  final bool isUpdating;

  const VacancyApplicationCard({
    super.key,
    required this.application,
    required this.onStatusChanged,
    this.isUpdating = false,
  });

  static const _statuses = ['Pending', 'Viewed', 'Interview', 'Accepted', 'Rejected'];

  String _statusLabel(String status) {
    switch (status) {
      case 'Pending':
        return 'На рассмотрении';
      case 'Viewed':
        return 'Просмотрено';
      case 'Interview':
        return 'Собеседование';
      case 'Accepted':
        return 'Принято';
      case 'Rejected':
        return 'Отклонено';
      default:
        return status;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Accepted':
        return const Color(0xFF059669);
      case 'Rejected':
        return const Color(0xFFDC2626);
      case 'Interview':
        return const Color(0xFF3157D5);
      case 'Viewed':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          Row(
            children: [
              Expanded(
                child: Text(application.candidateFullName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: Color(0xFFF3F5FF), shape: BoxShape.circle),
                child: Center(
                  child: Text('${application.matchScore}%',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF3157D5))),
                ),
              ),
            ],
          ),
          if (application.coverMessage != null && application.coverMessage!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(application.coverMessage!,
                style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)), maxLines: 3, overflow: TextOverflow.ellipsis),
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
            onChanged: isUpdating ? null : (value) { if (value != null) onStatusChanged(value); },
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFFF9FAFB),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
            ),
          ),
        ],
      ),
    );
  }
}