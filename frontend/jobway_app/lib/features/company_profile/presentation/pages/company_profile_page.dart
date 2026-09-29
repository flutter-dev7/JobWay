import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jobway_app/core/router/app_routes.dart';
import 'package:jobway_app/core/theme/app_theme_extension.dart';
import 'package:jobway_app/core/utils/image_utils.dart';
import 'package:jobway_app/core/widgets/display/info_row.dart';
import 'package:jobway_app/features/review/presentation/widgets/reviews_section.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/feedback/app_dialogs.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../../../../core/widgets/display/profile_photo.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../providers/company_profile_provider.dart';
import '../widgets/verification_badge.dart';

class CompanyProfilePage extends ConsumerStatefulWidget {
  const CompanyProfilePage({super.key});

  @override
  ConsumerState<CompanyProfilePage> createState() => _CompanyProfilePageState();
}

class _CompanyProfilePageState extends ConsumerState<CompanyProfilePage> {
  bool _isUploadingLogo = false;

  Future<void> _changeLogo() async {
    final source = await pickImageSourceDialog(context);
    if (source == null) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 85,
    );
    if (picked == null) return;

    setState(() => _isUploadingLogo = true);
    try {
      final file = await ImageUtils.ensureCompatibleFormat(File(picked.path));
      await ref.read(uploadCompanyLogoUseCaseProvider).call(file);
      ref.invalidate(companyProfileProvider);
      AppSnackbar.showSuccess('Лого обновлено');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(companyProfileProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Профиль компании',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                Icons.settings_outlined,
                size: 21,
                color: colors.textPrimary,
              ),
              onPressed: () => context.push(AppRoutes.settings),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: colors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: Icon(
                Icons.edit_outlined,
                size: 21,
                color: colors.textPrimary,
              ),
              onPressed: () async {
                final profile = profileAsync.valueOrNull;
                if (profile == null) return;

                await context.push(
                  AppRoutes.editCompanyProfile,
                  extra: profile,
                );
                ref.invalidate(companyProfileProvider);
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
            ),
          ),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            VerificationBadge(status: profile.verificationStatus),
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
                  ProfilePhoto(
                    photoUrl:
                        profile.logoUrl != null && profile.logoUrl!.isNotEmpty
                        ? '${ApiConstants.fileBaseUrl}${profile.logoUrl}'
                        : null,
                    fallbackText: profile.companyName.trim().isNotEmpty
                        ? profile.companyName.trim()[0].toUpperCase()
                        : '?',
                    onEdit: _changeLogo,
                    isUploading: _isUploadingLogo,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    profile.companyName,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  if (profile.location != null) ...[
                    const SizedBox(height: 7),
                    Text(
                      profile.location!,
                      style: TextStyle(
                        fontSize: 14,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (profile.description != null &&
                profile.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'О компании',
                icon: Icons.notes_rounded,
                child: Text(
                  profile.description!,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: colors.textSecondary,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            SectionCard(
              title: 'Информация',
              icon: Icons.info_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile.industry != null &&
                      profile.industry!.isNotEmpty) ...[
                    InfoRow(label: 'Индустрия', value: profile.industry!),
                    const SizedBox(height: 14),
                  ],
                  if (profile.website != null && profile.website!.isNotEmpty)
                    _WebsiteLine(url: profile.website!),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ReviewsSection(userId: profile.userId),
          ],
        ),
      ),
    );
  }
}

class _WebsiteLine extends StatelessWidget {
  final String url;

  const _WebsiteLine({required this.url});

  Future<void> _openWebsite() async {
    var normalizedUrl = url.trim();
    if (!normalizedUrl.startsWith('http://') &&
        !normalizedUrl.startsWith('https://')) {
      normalizedUrl = 'https://$normalizedUrl';
    }

    final uri = Uri.tryParse(normalizedUrl);
    if (uri == null) return;

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      AppSnackbar.showError('Не удалось открыть ссылку');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Сайт', style: TextStyle(fontSize: 12, color: colors.textMuted)),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: _openWebsite,
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
        ),
      ],
    );
  }
}
