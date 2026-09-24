// features/company_profile/presentation/pages/company_profile_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/widgets/app_dialogs.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/profile_photo.dart';
import '../../../../core/widgets/section_card.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/company_profile_provider.dart';
import '../widgets/verification_badge.dart';
import 'edit_company_profile_page.dart';

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

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;

    setState(() => _isUploadingLogo = true);
    try {
      await ref.read(uploadCompanyLogoUseCaseProvider).call(File(picked.path));
      ref.invalidate(companyProfileProvider);
      AppSnackbar.showSuccess('Лого обновлено');
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
    }
  }

  Future<void> _logout() async {
    final confirmed = await confirmLogoutDialog(context);
    if (!confirmed) return;

    await ref.read(authRepositoryProvider).logout();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(companyProfileProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: const Text('Профиль компании',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
        actions: [
          IconButton(
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: const Icon(Icons.logout_rounded, size: 20, color: Color(0xFFDC2626)),
            onPressed: _logout,
          ),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.edit_outlined, size: 21, color: Color(0xFF111827)),
              onPressed: () async {
                final profile = profileAsync.valueOrNull;
                if (profile == null) return;

                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => EditCompanyProfilePage(profile: profile)),
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
          child: Padding(padding: const EdgeInsets.all(24), child: Text(ApiException.extractMessage(error), textAlign: TextAlign.center)),
        ),
        data: (profile) => ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          children: [
            VerificationBadge(status: profile.verificationStatus),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.035), blurRadius: 20, offset: const Offset(0, 6))],
              ),
              child: Column(
                children: [
                  ProfilePhoto(
                    photoUrl: profile.logoUrl != null && profile.logoUrl!.isNotEmpty
                        ? '${ApiConstants.fileBaseUrl}${profile.logoUrl}'
                        : null,
                    fallbackText: profile.companyName.trim().isNotEmpty ? profile.companyName.trim()[0].toUpperCase() : '?',
                    onEdit: _changeLogo,
                    isUploading: _isUploadingLogo,
                  ),
                  const SizedBox(height: 14),
                  Text(profile.companyName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF111827))),
                  if (profile.location != null) ...[
                    const SizedBox(height: 7),
                    Text(profile.location!, style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280))),
                  ],
                ],
              ),
            ),
            if (profile.description != null && profile.description!.isNotEmpty) ...[
              const SizedBox(height: 16),
              SectionCard(
                title: 'О компании',
                icon: Icons.notes_rounded,
                child: Text(profile.description!, style: const TextStyle(fontSize: 14, height: 1.6, color: Color(0xFF4B5563))),
              ),
            ],
            const SizedBox(height: 16),
            SectionCard(
              title: 'Информация',
              icon: Icons.info_outline,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (profile.industry != null && profile.industry!.isNotEmpty) ...[
                    _InfoLine(label: 'Индустрия', value: profile.industry!),
                    const SizedBox(height: 14),
                  ],
                  if (profile.website != null && profile.website!.isNotEmpty) _WebsiteLine(url: profile.website!),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 3),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF111827))),
      ],
    );
  }
}

class _WebsiteLine extends StatelessWidget {
  final String url;

  const _WebsiteLine({required this.url});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Сайт', style: TextStyle(fontSize: 12, color: Color(0xFF9CA3AF))),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(color: const Color(0xFFF3F5FF), borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              const Icon(Icons.link, size: 16, color: Color(0xFF3157D5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(url, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF3157D5))),
              ),
            ],
          ),
        ),
      ],
    );
  }
}