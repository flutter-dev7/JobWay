import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme_extension.dart';

Future<bool> confirmLogoutDialog(BuildContext context) async {
  final result = await showCupertinoDialog<bool>(
    context: context,
    builder: (context) => CupertinoAlertDialog(
      title: const Text('Выйти из аккаунта?'),
      content: const Text(
        'Придётся войти заново, чтобы продолжить пользоваться приложением',
      ),
      actions: [
        CupertinoDialogAction(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Отмена'),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Выйти'),
        ),
      ],
    ),
  );
  return result ?? false;
}

Future<ImageSource?> pickImageSourceDialog(BuildContext context) {
  final colors = context.colors;

  return showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: colors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Фото профиля',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Выберите способ добавления фото',
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 20),
            _PhotoSourceTile(
              icon: Icons.camera_alt_rounded,
              iconBackground: const Color(0xFFDCE5FF),
              iconColor: const Color(0xFF3157D5),
              title: 'Сделать фото',
              subtitle: 'Открыть камеру',
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            const SizedBox(height: 10),
            _PhotoSourceTile(
              icon: Icons.photo_library_rounded,
              iconBackground: const Color(0xFFDCFCE7),
              iconColor: const Color(0xFF059669),
              title: 'Выбрать из галереи',
              subtitle: 'Загрузить существующее фото',
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: colors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Отмена',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PhotoSourceTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PhotoSourceTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceMuted,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBackground,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: colors.textMuted),
          ],
        ),
      ),
    );
  }
}
