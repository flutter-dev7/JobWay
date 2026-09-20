import 'package:flutter/material.dart';
import '../../domain/entities/job_application.dart';

class ApplicationCard extends StatelessWidget {
  final JobApplication application;

  const ApplicationCard({super.key, required this.application});

  Color _statusColor() {
    switch (application.status) {
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

  String _statusLabel() {
    switch (application.status) {
      case 'Pending':
        return 'На рассмотрении';
      case 'Viewed':
        return 'Просмотрено';
      case 'Interview':
        return 'Приглашение на собеседование';
      case 'Accepted':
        return 'Принято';
      case 'Rejected':
        return 'Отклонено';
      default:
        return application.status;
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
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(application.vacancyTitle,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                    const SizedBox(height: 2),
                    Text(application.companyName, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: const Color(0xFFF3F5FF), shape: BoxShape.circle),
                child: Center(
                  child: Text('${application.matchScore}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF3157D5))),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: _statusColor().withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(_statusLabel(),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _statusColor())),
          ),
        ],
      ),
    );
  }
}