import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import 'empty_state.dart';

class ExpensePieChart extends StatelessWidget {
  const ExpensePieChart({super.key, required this.data});

  final Map<String, double> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const EmptyState(
        icon: Icons.pie_chart_outline_rounded,
        title: 'Chưa có dữ liệu biểu đồ tròn',
        message: 'Hãy thêm giao dịch chi tiêu để xem tỷ lệ theo danh mục.',
      );
    }

    final List<MapEntry<String, double>> entries = data.entries.toList();
    final double total = data.values.fold<double>(
      0,
      (double sum, double value) => sum + value,
    );

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
            'Biểu đồ tròn chi tiêu theo danh mục',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 220,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 42,
                sectionsSpace: 3,
                sections: List<PieChartSectionData>.generate(entries.length, (
                  int index,
                ) {
                  final MapEntry<String, double> entry = entries[index];
                  final double percent = entry.value / total * 100;
                  final Color color = AppColors
                      .chartPalette[index % AppColors.chartPalette.length];

                  return PieChartSectionData(
                    color: color,
                    value: entry.value,
                    title: '${percent.toStringAsFixed(0)}%',
                    radius: 70,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List<Widget>.generate(entries.length, (int index) {
              final MapEntry<String, double> entry = entries[index];
              final Color color =
                  AppColors.chartPalette[index % AppColors.chartPalette.length];

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${entry.key}: ${CurrencyFormatter.format(entry.value)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
