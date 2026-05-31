import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';

const Color _background = Colors.black;
const Color _card = Color(0xFF1C1C1E);
const Color _softCard = Color(0xFF2C2C2E);
const Color _text = Colors.white;
const Color _muted = Color(0xFFA1A1AA);
const Color _divider = Color(0xFF34343A);
const Color _green = Color(0xFF34D399);
const Color _blue = Color(0xFF60A5FA);
const Color _red = Color(0xFFFB7185);

class MonthlyReportDetailScreen extends StatelessWidget {
  const MonthlyReportDetailScreen({
    super.key,
    required this.selectedMonth,
    required this.transactions,
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
  });

  final DateTime selectedMonth;
  final List<TransactionModel> transactions;
  final double balance;
  final double monthIncome;
  final double monthExpense;

  @override
  Widget build(BuildContext context) {
    final double openingBalance = _balanceBeforeMonth(
      transactions,
      selectedMonth,
    );
    final double endingBalance = openingBalance + monthIncome - monthExpense;
    final List<ReportSlice> incomeSlices = _buildReportSlices(
      transactions: transactions,
      selectedMonth: selectedMonth,
      type: AppConstants.incomeType,
    );
    final List<ReportSlice> expenseSlices = _buildReportSlices(
      transactions: transactions,
      selectedMonth: selectedMonth,
      type: AppConstants.expenseType,
    );

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      color: _green,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 74),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Số dư',
              style: TextStyle(
                color: _muted,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                CurrencyFormatter.format(balance),
                style: const TextStyle(
                  color: _text,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const SizedBox(height: 18),
            _TimeTabs(selectedMonth: selectedMonth),
            const SizedBox(height: 18),
            Row(
              children: <Widget>[
                Expanded(
                  child: _BalanceSnapshot(
                    label: 'Số dư đầu',
                    value: CurrencyFormatter.format(openingBalance),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BalanceSnapshot(
                    label: 'Số dư cuối',
                    value: CurrencyFormatter.format(endingBalance),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            NetIncomeCard(income: monthIncome, expense: monthExpense),
            const SizedBox(height: 18),
            GroupReportCard(
              income: monthIncome,
              expense: monthExpense,
              incomeSlices: incomeSlices,
              expenseSlices: expenseSlices,
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeTabs extends StatelessWidget {
  const _TimeTabs({required this.selectedMonth});

  final DateTime selectedMonth;

  @override
  Widget build(BuildContext context) {
    final List<String> tabs = <String>[
      DateFormat('yyyy').format(selectedMonth),
      DateFormat('MM/yyyy').format(selectedMonth),
      'THÁNG TRƯỚC',
      'THÁNG NÀY',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: <Widget>[
          for (final String tab in tabs)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: tab == 'THÁNG NÀY' ? _green : _card,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                tab,
                style: TextStyle(
                  color: tab == 'THÁNG NÀY' ? Colors.black : _text,
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BalanceSnapshot extends StatelessWidget {
  const _BalanceSnapshot({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                color: _text,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NetIncomeCard extends StatelessWidget {
  const NetIncomeCard({super.key, required this.income, required this.expense});

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final double netIncome = income - expense;
    final Color valueColor = netIncome < 0 ? _red : _blue;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Thu nhập ròng',
            style: TextStyle(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(netIncome),
              style: TextStyle(
                color: valueColor,
                fontSize: 30,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 20),
          IncomeExpenseBarComparison(income: income, expense: expense),
        ],
      ),
    );
  }
}

class IncomeExpenseBarComparison extends StatelessWidget {
  const IncomeExpenseBarComparison({
    super.key,
    required this.income,
    required this.expense,
  });

  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final double maxValue = math.max(income, expense);

    return Column(
      children: <Widget>[
        _ComparisonBar(
          label: 'Khoản thu',
          value: income,
          color: _blue,
          ratio: maxValue <= 0 ? 0 : income / maxValue,
        ),
        const SizedBox(height: 14),
        _ComparisonBar(
          label: 'Khoản chi',
          value: expense,
          color: _red,
          ratio: maxValue <= 0 ? 0 : expense / maxValue,
        ),
      ],
    );
  }
}

class _ComparisonBar extends StatelessWidget {
  const _ComparisonBar({
    required this.label,
    required this.value,
    required this.color,
    required this.ratio,
  });

  final String label;
  final double value;
  final Color color;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  CurrencyFormatter.format(value),
                  style: TextStyle(color: color, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 8,
            value: ratio.clamp(0, 1),
            color: color,
            backgroundColor: _softCard,
          ),
        ),
      ],
    );
  }
}

class GroupReportCard extends StatelessWidget {
  const GroupReportCard({
    super.key,
    required this.income,
    required this.expense,
    required this.incomeSlices,
    required this.expenseSlices,
  });

  final double income;
  final double expense;
  final List<ReportSlice> incomeSlices;
  final List<ReportSlice> expenseSlices;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Báo cáo theo nhóm',
            style: TextStyle(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: <Widget>[
              Expanded(
                child: _GroupSummaryMetric(
                  label: 'Khoản thu',
                  value: income,
                  color: _blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _GroupSummaryMetric(
                  label: 'Khoản chi',
                  value: expense,
                  color: _red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return _buildDonutLayout(
                constraints,
                incomeSlices,
                expenseSlices,
              );
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildDonutLayout(
  BoxConstraints constraints,
  List<ReportSlice> incomeSlices,
  List<ReportSlice> expenseSlices,
) {
  final bool compact = constraints.maxWidth < 360;
  final List<Widget> charts = <Widget>[
    DonutChartWithLegend(title: 'Khoản thu', slices: incomeSlices),
    DonutChartWithLegend(title: 'Khoản chi', slices: expenseSlices),
  ];

  if (compact) {
    return Column(
      children: <Widget>[charts[0], const SizedBox(height: 24), charts[1]],
    );
  }

  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      Expanded(child: charts[0]),
      const SizedBox(width: 18),
      Expanded(child: charts[1]),
    ],
  );
}

class _GroupSummaryMetric extends StatelessWidget {
  const _GroupSummaryMetric({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _softCard,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(color: _muted, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(value),
              style: TextStyle(
                color: color,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DonutChartWithLegend extends StatelessWidget {
  const DonutChartWithLegend({
    super.key,
    required this.title,
    required this.slices,
  });

  final String title;
  final List<ReportSlice> slices;

  @override
  Widget build(BuildContext context) {
    final double total = slices.fold<double>(
      0,
      (double sum, ReportSlice slice) => sum + slice.amount,
    );

    return Column(
      children: <Widget>[
        Text(
          title,
          style: const TextStyle(color: _text, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 128,
          height: 128,
          child: CustomPaint(
            painter: DonutChartPainter(slices: slices),
            child: Center(
              child: Text(
                total <= 0 ? '0%' : '100%',
                style: const TextStyle(
                  color: _text,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (slices.isEmpty)
          const Text(
            'Chưa có dữ liệu',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12),
          )
        else
          for (final ReportSlice slice in slices.take(3))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: <Widget>[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: slice.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slice.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _muted, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
      ],
    );
  }
}

class DonutChartPainter extends CustomPainter {
  const DonutChartPainter({required this.slices});

  final List<ReportSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final double total = slices.fold<double>(
      0,
      (double sum, ReportSlice slice) => sum + slice.amount,
    );
    final Rect rect = Offset.zero & size;
    double startAngle = -math.pi / 2;

    if (total <= 0) {
      canvas.drawArc(
        rect.deflate(10),
        0,
        math.pi * 2,
        false,
        Paint()
          ..color = _divider
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    for (final ReportSlice slice in slices) {
      final double sweepAngle = slice.amount / total * math.pi * 2;
      canvas.drawArc(
        rect.deflate(10),
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 18
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant DonutChartPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class ReportSlice {
  const ReportSlice({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
}

List<ReportSlice> _buildReportSlices({
  required List<TransactionModel> transactions,
  required DateTime selectedMonth,
  required String type,
}) {
  final Map<String, double> grouped = <String, double>{};

  for (final TransactionModel transaction in transactions) {
    if (transaction.type != type ||
        transaction.date.year != selectedMonth.year ||
        transaction.date.month != selectedMonth.month) {
      continue;
    }

    grouped.update(
      transaction.category,
      (double value) => value + transaction.amount,
      ifAbsent: () => transaction.amount,
    );
  }

  final List<MapEntry<String, double>> entries = grouped.entries.toList()
    ..sort(
      (MapEntry<String, double> a, MapEntry<String, double> b) =>
          b.value.compareTo(a.value),
    );

  return entries.map((MapEntry<String, double> entry) {
    return ReportSlice(
      label: entry.key,
      amount: entry.value,
      color: _colorForLabel(entry.key),
      icon: AppConstants.categoryIcon(entry.key, type),
    );
  }).toList();
}

double _balanceBeforeMonth(
  List<TransactionModel> transactions,
  DateTime selectedMonth,
) {
  final DateTime monthStart = DateTime(selectedMonth.year, selectedMonth.month);

  return transactions
      .where(
        (TransactionModel transaction) => transaction.date.isBefore(monthStart),
      )
      .fold<double>(0, (double sum, TransactionModel transaction) {
        if (transaction.type == AppConstants.incomeType) {
          return sum + transaction.amount;
        }
        if (transaction.type == AppConstants.expenseType) {
          return sum - transaction.amount;
        }
        return sum;
      });
}

Color _colorForLabel(String label) {
  final int index = label.hashCode.abs() % 6;
  return <Color>[
    _red,
    _green,
    _blue,
    const Color(0xFFF59E0B),
    const Color(0xFFA78BFA),
    const Color(0xFF22D3EE),
  ][index];
}
