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
const Color _green = Color(0xFF34D399);
const Color _red = Color(0xFFFB7185);
const Color _divider = Color(0xFF34343A);

class SpendingDetailScreen extends StatelessWidget {
  const SpendingDetailScreen({
    super.key,
    required this.selectedMonth,
    required this.transactions,
  });

  final DateTime selectedMonth;
  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    final List<SpendingSlice> slices = _buildSpendingSlices(
      transactions,
      selectedMonth,
    );

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: <Widget>[
            const _SpendingHeader(),
            const SizedBox(height: 18),
            _TimeTabs(selectedMonth: selectedMonth),
            const SizedBox(height: 14),
            const _TypeFilter(),
            const SizedBox(height: 22),
            SpendingDonutChart(slices: slices),
            const SizedBox(height: 22),
            SpendingCategoryList(slices: slices),
          ],
        ),
      ),
    );
  }
}

class _SpendingHeader extends StatelessWidget {
  const _SpendingHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Đóng',
            style: TextStyle(color: _green, fontWeight: FontWeight.w800),
          ),
        ),
        const Expanded(
          child: Text(
            'Chi tiêu',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _text,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.calendar_month_rounded, color: _text),
        ),
      ],
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

class _TypeFilter extends StatelessWidget {
  const _TypeFilter();

  @override
  Widget build(BuildContext context) {
    const List<String> filters = <String>['Chi tiêu', 'Thu nhập', 'Tất cả'];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: <Widget>[
          for (int index = 0; index < filters.length; index++)
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: index == 0 ? _softCard : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  filters[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: index == 0 ? _text : _muted,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SpendingDonutChart extends StatelessWidget {
  const SpendingDonutChart({super.key, required this.slices});

  final List<SpendingSlice> slices;

  @override
  Widget build(BuildContext context) {
    final double total = slices.fold<double>(
      0,
      (double sum, SpendingSlice slice) => sum + slice.amount,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: _SpendingDonutPainter(slices: slices),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Tổng chi',
                      style: TextStyle(
                        color: _muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        CurrencyFormatter.format(total),
                        style: const TextStyle(
                          color: _red,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          if (slices.isEmpty)
            const Text(
              'Chưa có dữ liệu chi tiêu trong tháng này',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: <Widget>[
                for (final SpendingSlice slice in slices.take(5))
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: slice.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        slice.label,
                        style: const TextStyle(color: _muted, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SpendingDonutPainter extends CustomPainter {
  const _SpendingDonutPainter({required this.slices});

  final List<SpendingSlice> slices;

  @override
  void paint(Canvas canvas, Size size) {
    final double total = slices.fold<double>(
      0,
      (double sum, SpendingSlice slice) => sum + slice.amount,
    );
    final Rect rect = Offset.zero & size;
    double startAngle = -math.pi / 2;

    if (total <= 0) {
      canvas.drawArc(
        rect.deflate(18),
        0,
        math.pi * 2,
        false,
        Paint()
          ..color = _divider
          ..style = PaintingStyle.stroke
          ..strokeWidth = 28
          ..strokeCap = StrokeCap.round,
      );
      return;
    }

    for (final SpendingSlice slice in slices) {
      final double sweep = slice.amount / total * math.pi * 2;
      canvas.drawArc(
        rect.deflate(18),
        startAngle,
        sweep,
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 28
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _SpendingDonutPainter oldDelegate) {
    return oldDelegate.slices != slices;
  }
}

class SpendingCategoryList extends StatelessWidget {
  const SpendingCategoryList({super.key, required this.slices});

  final List<SpendingSlice> slices;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: slices.isEmpty
          ? const Text(
              'Chưa có nhóm chi tiêu để hiển thị.',
              textAlign: TextAlign.center,
              style: TextStyle(color: _muted, fontWeight: FontWeight.w700),
            )
          : Column(
              children: <Widget>[
                for (int index = 0; index < slices.length; index++) ...<Widget>[
                  SpendingCategoryItem(slice: slices[index]),
                  if (index < slices.length - 1) const SizedBox(height: 18),
                ],
              ],
            ),
    );
  }
}

class SpendingCategoryItem extends StatelessWidget {
  const SpendingCategoryItem({super.key, required this.slice});

  final SpendingSlice slice;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundColor: slice.color.withValues(alpha: 0.16),
          child: Icon(slice.icon, color: slice.color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            slice.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _text,
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              CurrencyFormatter.format(slice.amount),
              style: const TextStyle(
                color: _red,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        const Icon(Icons.chevron_right_rounded, color: _muted),
      ],
    );
  }
}

class SpendingSlice {
  const SpendingSlice({
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

List<SpendingSlice> _buildSpendingSlices(
  List<TransactionModel> transactions,
  DateTime selectedMonth,
) {
  final Map<String, double> grouped = <String, double>{};

  for (final TransactionModel transaction in transactions) {
    if (transaction.type != AppConstants.expenseType ||
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
    return SpendingSlice(
      label: entry.key,
      amount: entry.value,
      color: _colorForLabel(entry.key),
      icon: AppConstants.categoryIcon(entry.key, AppConstants.expenseType),
    );
  }).toList();
}

Color _colorForLabel(String label) {
  final int index = label.hashCode.abs() % 6;
  return <Color>[
    _red,
    _green,
    const Color(0xFF60A5FA),
    const Color(0xFFF59E0B),
    const Color(0xFFA78BFA),
    const Color(0xFF22D3EE),
  ][index];
}
