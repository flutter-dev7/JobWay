import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/widgets/display/info_row.dart';
import 'package:jobway_app/features/review/presentation/widgets/reviews_section.dart';
import 'package:jobway_app/features/vacancies/presentation/widgets/vacancy_card.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/display/company_avatar.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/navigation/app_page_app_bar.dart';
import '../providers/search_provider.dart';

class CompanyPublicPage extends ConsumerWidget {
  final String companyId;

  const CompanyPublicPage({super.key, required this.companyId});

  Widget _buildVacancies(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final async = ref.watch(publicCompanyVacanciesProvider(companyId));

    final vacancies = async.valueOrNull;
    if (vacancies == null) {
      return async.hasError
          ? Text(
              ApiException.extractMessage(async.error!),
              style: TextStyle(fontSize: 13, color: colors.textMuted),
            )
          : const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Открытые вакансии (${vacancies.length})',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        if (vacancies.isEmpty)
          Text(
            'Сейчас у компании нет открытых вакансий',
            style: TextStyle(fontSize: 13, color: colors.textMuted),
          )
        else
          ...vacancies.map(
            (vacancy) => VacancyCard(
              vacancy: vacancy,
              onTap: () => context.push(AppRoutes.vacancy(vacancy.id)),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final profileAsync = ref.watch(publicCompanyProvider(companyId));

    return Scaffold(
      backgroundColor: colors.background,
      appBar: appPageAppBar(context, 'Компания'),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              ApiException.extractMessage(error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (company) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(publicCompanyVacanciesProvider(companyId));
            ref.invalidate(publicCompanyProvider(companyId));
            await ref.read(publicCompanyProvider(companyId).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(
                        Theme.of(context).brightness == Brightness.dark ? 0.2 : 0.035,
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
                    if (company.location != null && company.location!.isNotEmpty) ...[
                      const SizedBox(height: 7),
                      Text(
                        company.location!,
                        style: TextStyle(fontSize: 14, color: colors.textSecondary),
                      ),
                    ],
                  ],
                ),
              ),
              if (company.description != null && company.description!.isNotEmpty) ...[
                const SizedBox(height: 16),
                SectionCard(
                  title: 'О компании',
                  icon: Icons.notes_rounded,
                  child: Text(
                    company.description!,
                    style: TextStyle(fontSize: 14, height: 1.6, color: colors.textSecondary),
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
                      if (company.industry != null && company.industry!.isNotEmpty) ...[
                        InfoRow(label: 'Индустрия', value: company.industry!),
                        const SizedBox(height: 14),
                      ],
                      if (company.website != null && company.website!.isNotEmpty)
                        _WebsiteTile(url: company.website!),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              _buildVacancies(context, ref),
              const SizedBox(height: 16),
              ReviewsSection(userId: company.userId),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebsiteTile extends StatelessWidget {
  final String url;

  const _WebsiteTile({required this.url});

  Future<void> _open() async {
    var normalized = url.trim();
    if (!normalized.startsWith('http://') && !normalized.startsWith('https://')) {
      normalized = 'https://$normalized';
    }

    final uri = Uri.tryParse(normalized);
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

    return GestureDetector(
      onTap: _open,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.link, size: 16, color: context.accentColor),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                url,
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
    );
  }
}