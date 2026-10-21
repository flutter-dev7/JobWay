import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import 'subscription_sheet.dart';

class ProLocked extends StatelessWidget {
  final bool locked;
  final String title;
  final String description;
  final String companyName;
  final Widget child;

  const ProLocked({
    super.key,
    required this.locked,
    required this.title,
    this.description = 'Доступно на тарифе Pro',
    this.companyName = '',
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (!locked) return child;

    final colors = context.colors;
    const proColor = Color(0xFFF59E0B);

    return GestureDetector(
      onTap: () => SubscriptionSheet.show(context, companyName: companyName),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.border),
        ),
        child: Column(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: proColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.lock_outline_rounded, size: 22, color: proColor),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
            const SizedBox(height: 12),
            Text(
              'Открыть с Pro',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: context.accentColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}