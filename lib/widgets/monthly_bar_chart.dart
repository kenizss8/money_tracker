import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../models/transaction_model.dart';
import '../utils/app_colors.dart';
import '../utils/date_formatter.dart';
import 'empty_state.dart';

class MonthlyBarChart extends StatelessWidget {
  const MonthlyBarChart({super.key, required this.points});

  final List<MonthlyExpensePoint> points;

  @override
  Widget build(BuildContext context) {
    final double maxValue = points.fold<double>(
      0,
      (double currentMax, MonthlyExpensePoint point) =>
          math.max(currentMax, point.total),
    );

    if (points.isEmpty || maxValue == 0) {
      return const EmptyState(
        icon: Icons.bar_chart_rounded,
        title: 'Chưa có dữ liệu biểu đồ cột',
        message:
            'Khi có chi tiêu, biểu đồ sẽ hiển thị tổng chi của 6 tháng gần nhất.',
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Biểu đồ cột chi tiêu 6 tháng gần nhất',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 240,
            child: BarChart(
              BarChartData(
                maxY: maxValue * 1.25,
                alignment: BarChartAlignment.spaceAround,
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: maxValue == 0 ? 1 : maxValue / 4,
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 34,
                      interval: maxValue == 0 ? 1 : maxValue / 4,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          value == 0 ? '0' : '${(value / 1000).round()}K',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        final int index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            DateFormatter.formatShortMonth(points[index].month),
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List<BarChartGroupData>.generate(points.length, (
                  int index,
                ) {
                  final MonthlyExpensePoint point = points[index];
                  return BarChartGroupData(
                    x: index,
                    barRods: <BarChartRodData>[
                      BarChartRodData(
                        toY: point.total,
                        width: 22,
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: <Color>[
                            AppColors.secondary,
                            AppColors.accent,
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
