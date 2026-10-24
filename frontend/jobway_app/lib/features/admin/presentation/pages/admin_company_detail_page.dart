import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jobway_app/core/utils/time_ago.dart';
import 'package:jobway_app/features/admin/presentation/widgets/admin_company_vacancies_section.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/buttons/app_button.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../../../company_profile/presentation/widgets/verification_badge.dart';
import '../../../review/presentation/widgets/reviews_section.dart';
import '../../domain/entities/company_moderation.dart';
import '../providers/admin_provider.dart';

class AdminCompanyDetailPage extends ConsumerStatefulWidget {
  final CompanyModeration company;

  const AdminCompanyDetailPage({super.key, required this.company});

  @override
  ConsumerState<AdminCompanyDetailPage> createState() =>
      _AdminCompanyDetailPageState();
}

class _AdminCompanyDetailPageState
    extends ConsumerState<AdminCompanyDetailPage> {
  static const _durations = [30, 90, 365];

  late CompanyModeration _company = widget.company;
  int _days = 30;
  bool _isSaving = false;

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

  Future<void> _setTier(String tier) async {
    setState(() => _isSaving = true);
    try {
      final updated = await ref
          .read(setCompanyTierUseCaseProvider)
          .call(_company.id, tier: tier, days: _days);
      if (!mounted) return;

      ref
          .read(adminCompaniesControllerProvider.notifier)
          .replaceCompany(updated);
      setState(() => _company = updated);
      AppSnackbar.showSuccess(
        tier == 'Pro' ? 'Тариф Pro выдан' : 'Тариф изменён на Free',
      );
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _confirmDowngrade() async {
    final confirmed = await showCupertinoDialog<bool>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Перевести на Free?'),
        content: const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'Pro будет отключён сразу, оставшийся срок сгорит.',
            textAlign: TextAlign.center,
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Отмена'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Перевести'),
          ),
        ],
      ),
    );

    if (confirmed == true) _setTier('Free');
  }

    Widget _buildTierSection() {
    final colors = context.colors;
    const proColor = Color(0xFFF59E0B);
    final tierColor = _company.isPro ? proColor : colors.textSecondary;
    final isVerified = _company.verificationStatus == 'Verified';

    return SectionCard(
      title: 'Тариф',
      icon: Icons.workspace_premium_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: tierColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _company.isPro ? 'Pro' : 'Free',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: tierColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _company.isPro && _company.tierExpiresAt != null
                      ? 'Действует до ${TimeAgo.formatDate(_company.tierExpiresAt!)}'
                      : 'Без подписки',
                  style: TextStyle(fontSize: 13, color: colors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (!isVerified)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: colors.textMuted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Тариф Pro можно выдать только после верификации компании.',
                      style: TextStyle(fontSize: 13, height: 1.4, color: colors.textSecondary),
                    ),
                  ),
                ],
              ),
            )
          else ...[
            Text(
              'На сколько дней выдать или продлить',
              style: TextStyle(fontSize: 12, color: colors.textMuted),
            ),
            const SizedBox(height: 8),
            Row(
              children: _durations.map((days) {
                final isSelected = _days == days;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _days = days),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.textPrimary : colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '$days дн.',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? colors.surface : colors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: _company.isPro ? 'Продлить Pro' : 'Выдать Pro',
              isLoading: _isSaving,
              onPressed: () => _setTier('Pro'),
            ),
            if (_company.isPro) ...[
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: _isSaving ? null : _confirmDowngrade,
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFFDC2626)),
                  child: const Text('Перевести на Free'),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final company = _company;

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
          const SizedBox(height: 16),
          _buildTierSection(),
          const SizedBox(height: 16),
          AdminCompanyVacanciesSection(companyId: company.id),
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
