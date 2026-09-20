import 'package:flutter/material.dart';
import '../../domain/entities/company_moderation.dart';

class CompanyModerationCard extends StatelessWidget {
  final CompanyModeration company;
  final VoidCallback onVerify;
  final VoidCallback onReject;
  final bool isUpdating;

  const CompanyModerationCard({
    super.key,
    required this.company,
    required this.onVerify,
    required this.onReject,
    this.isUpdating = false,
  });

  Color _statusColor() {
    switch (company.verificationStatus) {
      case 'Verified':
        return const Color(0xFF059669);
      case 'Rejected':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }

  String _statusLabel() {
    switch (company.verificationStatus) {
      case 'Verified':
        return 'Верифицирована';
      case 'Rejected':
        return 'Отклонена';
      case 'Pending':
        return 'На рассмотрении';
      default:
        return 'Не верифицирована';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    final isFinal = company.verificationStatus == 'Verified';

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
                child: Text(company.companyName,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(_statusLabel(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
              ),
            ],
          ),
          if (company.industry != null || company.location != null) ...[
            const SizedBox(height: 6),
            Text(
              [company.industry, company.location].where((e) => e != null && e.isNotEmpty).join(' · '),
              style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
          if (!isFinal) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating ? null : onVerify,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF059669),
                      side: const BorderSide(color: Color(0xFFBBF7D0)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Верифицировать'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: isUpdating ? null : onReject,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFDC2626),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('Отклонить'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}