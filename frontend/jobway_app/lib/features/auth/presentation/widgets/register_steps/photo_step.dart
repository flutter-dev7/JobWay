import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../../core/theme/app_theme_extension.dart';
import '../../../../../core/widgets/buttons/app_button.dart';

class PhotoStep extends StatelessWidget {
  final String role;
  final File? pickedPhoto;
  final bool isLoading;
  final VoidCallback onPickPhoto;
  final VoidCallback onSubmit;

  const PhotoStep({
    super.key,
    required this.role,
    required this.pickedPhoto,
    required this.isLoading,
    required this.onPickPhoto,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          role == 'Candidate' ? 'Добавьте фото профиля' : 'Добавьте лого компании',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: colors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text('Необязательно — можно добавить позже в профиле', style: TextStyle(fontSize: 14, color: colors.textSecondary)),
        const SizedBox(height: 32),
        Center(
          child: GestureDetector(
            onTap: onPickPhoto,
            child: pickedPhoto != null
                ? ClipOval(child: Image.file(pickedPhoto!, width: 120, height: 120, fit: BoxFit.cover))
                : Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: colors.surfaceMuted,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.accentColor, width: 2),
                    ),
                    child: Icon(Icons.add_a_photo_outlined, size: 32, color: context.accentColor),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: GestureDetector(
            onTap: onPickPhoto,
            child: Text(
              pickedPhoto != null ? 'Изменить фото' : 'Нажмите, чтобы добавить фото',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: context.accentColor),
            ),
          ),
        ),
        const SizedBox(height: 40),
        AppButton(label: 'Завершить регистрацию', isLoading: isLoading, onPressed: onSubmit),
      ],
    );
  }
}