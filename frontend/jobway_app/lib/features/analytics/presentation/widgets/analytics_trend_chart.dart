import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme_extension.dart';

class AnalyticsTrendPoint {
  final String label;
  final int value;
  final Color? color;

  const AnalyticsTrendPoint({
    required this.label,
    required this.value,
    this.color,
  });
}

class AnalyticsTrendChart extends StatelessWidget {
  final List<AnalyticsTrendPoint> points;
  final Color lineColor;

  const AnalyticsTrendChart({
    super.key,
    required this.points,
    required this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final maxValue = points
        .map((e) => e.value)
        .fold<int>(0, (a, b) => a > b ? a : b);
    final maxY = maxValue == 0 ? 5.0 : maxValue * 1.35;
    final interval = maxY / 4;

    return SizedBox(
      height: 210,
      child: LineChart(
        LineChartData(
          minY: 0,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (value) =>
                FlLine(color: colors.border, strokeWidth: 1),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: interval,
                getTitlesWidget: (value, meta) => Text(
                  value.round().toString(),
                  style: TextStyle(fontSize: 10, color: colors.textMuted),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= points.length)
                    return const SizedBox.shrink();

                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: SizedBox(
                      width: 56,
                      child: Text(
                        points[index].label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            enabled: true,
            handleBuiltInTouches: true,
            getTouchedSpotIndicator: (barData, indexes) => indexes
                .map(
                  (i) => TouchedSpotIndicatorData(
                    FlLine(color: lineColor.withOpacity(0.4), strokeWidth: 2),
                    FlDotData(
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 5,
                            color: points[index].color ?? lineColor,
                            strokeWidth: 2,
                            strokeColor: colors.surface,
                          ),
                    ),
                  ),
                )
                .toList(),
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => colors.textPrimary,
              tooltipPadding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              getTooltipItems: (spots) => spots.map((spot) {
                final point = points[spot.x.toInt()];
                return LineTooltipItem(
                  '${point.label}\n',
                  TextStyle(
                    color: colors.surface,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  children: [
                    TextSpan(
                      text: '${point.value}',
                      style: TextStyle(
                        color: colors.surface,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: List.generate(
                points.length,
                (i) => FlSpot(i.toDouble(), points[i].value.toDouble()),
              ),
              isCurved: true,
              curveSmoothness: 0.3,
              color: lineColor,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) =>
                    FlDotCirclePainter(
                      radius: 4,
                      color: points[index].color ?? lineColor,
                      strokeWidth: 2,
                      strokeColor: colors.surface,
                    ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    lineColor.withOpacity(0.28),
                    lineColor.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
