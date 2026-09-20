import 'package:flutter/material.dart';
import '../../domain/entities/vacancy.dart';

class MyVacancyCard extends StatelessWidget {
  final Vacancy vacancy;
  final VoidCallback? onPublish;
  final VoidCallback? onClose;
  final VoidCallback? onTap;
  final bool isUpdating;

  const MyVacancyCard({
    super.key,
    required this.vacancy,
    this.onPublish,
    this.onClose,
    this.onTap,
    this.isUpdating = false,
  });

  Color _statusColor() {
    switch (vacancy.status) {
      case 'Active':
        return const Color(0xFF059669);
      case 'Closed':
        return const Color(0xFF6B7280);
      case 'Archived':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFFD97706);
    }
  }

  String _statusLabel() {
    switch (vacancy.status) {
      case 'Draft':
        return 'Черновик';
      case 'Active':
        return 'Активна';
      case 'Closed':
        return 'Закрыта';
      case 'Archived':
        return 'В архиве';
      default:
        return vacancy.status;
    }
  }

  // features/vacancies/presentation/widgets/my_vacancy_card.dart — заменить метод build целиком
  @override
  Widget build(BuildContext context) {
    final color = _statusColor();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    vacancy.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _statusLabel(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (vacancy.status == 'Draft' || vacancy.status == 'Active')
              Row(
                children: [
                  if (vacancy.status == 'Draft')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isUpdating ? null : onPublish,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111827),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Опубликовать'),
                      ),
                    ),
                  if (vacancy.status == 'Active')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: isUpdating ? null : onClose,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFDC2626),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Закрыть'),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
