import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';
import '../../../../core/utils/enum_labels.dart';
import '../../domain/entities/employer_analytics.dart';

class StatusFunnelRow extends StatelessWidget {
  final StatusFunnelItem item;

  const StatusFunnelRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: applicationStatusColor(item.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              applicationStatusLabel(item.status),
              style: TextStyle(color: colors.textPrimary),
            ),
          ),
          Text(
            '${item.count}',
            style: TextStyle(fontWeight: FontWeight.w600, color: colors.textPrimary),
          ),
        ],
      ),
    );
  }
}