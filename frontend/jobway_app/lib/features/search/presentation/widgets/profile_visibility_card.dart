import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_exception.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/widgets/display/section_card.dart';
import '../../../../core/widgets/feedback/app_snackbar.dart';
import '../providers/search_provider.dart';

class ProfileVisibilityCard extends ConsumerStatefulWidget {
  const ProfileVisibilityCard({super.key});

  @override
  ConsumerState<ProfileVisibilityCard> createState() => _ProfileVisibilityCardState();
}

class _ProfileVisibilityCardState extends ConsumerState<ProfileVisibilityCard> {
  bool _isSaving = false;

  Future<void> _toggle(bool value) async {
    setState(() => _isSaving = true);
    try {
      await ref.read(searchRemoteDataSourceProvider).setVisibility(value);
      ref.invalidate(profileVisibilityProvider);
      AppSnackbar.showSuccess(
        value ? 'Профиль виден работодателям' : 'Профиль скрыт из поиска',
      );
    } catch (error) {
      AppSnackbar.showError(ApiException.extractMessage(error));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isVisible = ref.watch(profileVisibilityProvider).valueOrNull;

    // Для работодателя и администратора (и пока не загрузилось) карточки нет
    if (isVisible == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SectionCard(
        title: 'Приватность',
        icon: Icons.visibility_outlined,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Виден работодателям',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Верифицированные компании смогут найти вас в поиске и увидеть '
                    'имя, фото, город, навыки и резюме. Дата рождения не показывается. '
                    'Компании, на вакансии которых вы откликнулись, видят ваш профиль в любом случае.',
                    style: TextStyle(fontSize: 12, height: 1.5, color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Switch(
              value: isVisible,
              onChanged: _isSaving ? null : _toggle,
              activeColor: context.accentColor,
              activeTrackColor: context.accentColor.withOpacity(0.2),
            ),
          ],
        ),
      ),
    );
  }
}