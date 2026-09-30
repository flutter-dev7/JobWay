// features/admin/presentation/widgets/company_moderation_card.dart
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../domain/entities/company_moderation.dart';

class CompanyModerationCard extends StatelessWidget {
  final CompanyModeration company;
  final VoidCallback onVerify;
  final VoidCallback onReject;
  final VoidCallback? onTap;
  final bool isUpdating;

  const CompanyModerationCard({
    super.key,
    required this.company,
    required this.onVerify,
    required this.onReject,
    this.onTap,
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
    final colors = context.colors;
    final color = _statusColor();
    final isVerified = company.verificationStatus == 'Verified';
    final isRejected = company.verificationStatus == 'Rejected';

    return GestureDetector(
      onTap: onTap,
      child: Container(
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
                  companyName: company.companyName,
                  logoUrl: company.logoUrl,
                  size: 44,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.companyName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      if (company.industry != null ||
                          company.location != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          [
                            company.industry,
                            company.location,
                          ].where((e) => e != null && e.isNotEmpty).join(' · '),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            if (!isVerified) ...[
              const SizedBox(height: 14),
              Divider(height: 1, color: colors.border),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: isUpdating ? null : onVerify,
                      icon: const Icon(Icons.verified_outlined, size: 16),
                      label: const Text('Верифицировать'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF059669),
                        side: const BorderSide(color: Color(0xFFBBF7D0)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  if (!isRejected) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isUpdating ? null : onReject,
                        icon: const Icon(Icons.close_rounded, size: 16),
                        label: const Text('Отклонить'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
