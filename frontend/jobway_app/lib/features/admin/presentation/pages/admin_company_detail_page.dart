import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../company_profile/presentation/widgets/verification_badge.dart';
import '../../../review/presentation/widgets/reviews_section.dart';
import '../../domain/entities/company_moderation.dart';

class AdminCompanyDetailPage extends StatelessWidget {
  final CompanyModeration company;

  const AdminCompanyDetailPage({super.key, required this.company});

  Future<void> _openWebsite(String url) async {
    var normalizedUrl = url.trim();
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) return;

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      AppSnackbar.showError('Не удалось открыть ссылку');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Профиль компании'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          VerificationBadge(status: company.verificationStatus),
          const SizedBox(height: 16),
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
                CompanyAvatar(
                  companyName: company.companyName,
                  logoUrl: company.logoUrl,
                  size: 72,
                ),
                const SizedBox(height: 14),
                Text(
                  company.companyName,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                if (company.location != null &&
                    company.location!.isNotEmpty) ...[
                  const SizedBox(height: 7),
                  Text(
                    company.location!,
                    style: TextStyle(fontSize: 14, color: colors.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          if (company.description != null &&
              company.description!.isNotEmpty) ...[
            const SizedBox(height: 16),
            SectionCard(
              title: 'О компании',
              icon: Icons.notes_rounded,
              child: Text(
                company.description!,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: colors.textSecondary,
                ),
              ),
            ),
          ],
          if ((company.industry != null && company.industry!.isNotEmpty) ||
              (company.website != null && company.website!.isNotEmpty)) ...[
            const SizedBox(height: 16),
            SectionCard(
              title: 'Информация',
              icon: Icons.info_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (company.industry != null &&
                      company.industry!.isNotEmpty) ...[
                    Text(
                      'Индустрия',
                      style: TextStyle(fontSize: 12, color: colors.textMuted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.industry!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                  if (company.industry != null &&
                      company.industry!.isNotEmpty &&
                      company.website != null &&
                      company.website!.isNotEmpty)
                    const SizedBox(height: 14),
                  if (company.website != null && company.website!.isNotEmpty)
                    GestureDetector(
                      onTap: () => _openWebsite(company.website!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colors.surfaceMuted,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.link,
                              size: 16,
                              color: context.accentColor,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                company.website!,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: context.accentColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          ReviewsSection(userId: company.userId),
        ],
      ),
    );
  }
}
