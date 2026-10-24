import 'package:flutter/material.dart';
import '../../theme/app_theme_extension.dart';

class ProfileCompletionCard extends StatelessWidget {
  final int total;
  final List<String> missing;
  final VoidCallback onFill;

  const ProfileCompletionCard({
    super.key,
    required this.total,
    required this.missing,
    required this.onFill,
  });

  @override
  Widget build(BuildContext context) {
    if (missing.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;
    final accent = context.accentColor;
    final done = (total - missing.length).clamp(0, total);
    final progress = total == 0 ? 0.0 : done / total;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withOpacity(0.35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.edit_note_rounded, size: 22, color: accent),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Заполните профиль',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      Text(
                        'Заполнено ${(progress * 100).round()}%',
                        style: TextStyle(fontSize: 12, color: colors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: colors.surfaceMuted,
                valueColor: AlwaysStoppedAnimation<Color>(accent),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Не хватает:',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: missing
                  .map(
                    (item) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: colors.surfaceMuted,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        item,
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: onFill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.textPrimary,
                  foregroundColor: colors.surface,
                  elevation: 0,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Заполнить',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}