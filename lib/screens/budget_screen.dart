import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_constants.dart';
import 'budget_editor_screen.dart';

const Color _budgetBackground = Color(0xFF000000);
const Color _budgetCard = Color(0xFF1C1C1E);
const Color _budgetCardSoft = Color(0xFF2C2C2E);
const Color _budgetText = Color(0xFFFFFFFF);
const Color _budgetTextMuted = Color(0xFFA1A1AA);
const Color _budgetDivider = Color(0xFF34343A);
const Color _budgetGreen = Color(0xFF34D399);
const Color _budgetBlue = Color(0xFF2563EB);
const Color _budgetBlueSoft = Color(0xFF60A5FA);
const Color _budgetRed = Color(0xFFFB7185);

final NumberFormat _budgetMoneyFormat = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '',
  decimalDigits: 2,
);

class BudgetScreen extends StatelessWidget {
  const BudgetScreen({super.key});

  Future<void> _openBudgetEditor(BuildContext context) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const BudgetEditorScreen()),
    );

    if (!context.mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _budgetBackground,
      body: SafeArea(
        child: Consumer2<BudgetProvider, TransactionProvider>(
          builder:
              (
                BuildContext context,
                BudgetProvider budgetProvider,
                TransactionProvider transactionProvider,
                Widget? child,
              ) {
                final double totalBudget =
                    budgetProvider.currentBudget?.amount ?? 0;
                final double totalSpent =
                    transactionProvider.selectedMonthExpense;
                final double availableAmount = totalBudget - totalSpent;
                final double progress = totalBudget <= 0
                    ? 0
                    : (totalSpent / totalBudget).clamp(0.0, 1.0);
                final int daysLeft = _daysLeftInMonth(
                  transactionProvider.selectedMonth,
                );
                final List<BudgetCategoryData> categories =
                    _buildBudgetCategories(
                      expenseByCategory:
                          transactionProvider.expenseByCategorySelectedMonth,
                      totalBudget: totalBudget,
                    );
                final double todayProgress = _monthElapsedProgress(
                  transactionProvider.selectedMonth,
                );

                return CustomScrollView(
                  slivers: <Widget>[
                    const SliverToBoxAdapter(child: BudgetHeader()),
                    const SliverToBoxAdapter(child: BudgetTimeTab()),
                    SliverToBoxAdapter(
                      child: BudgetOverviewCard(
                        totalBudget: totalBudget,
                        totalSpent: totalSpent,
                        availableAmount: availableAmount,
                        progress: progress,
                        daysLeft: daysLeft,
                        isLoading: budgetProvider.isLoading,
                        onCreateBudget: () => _openBudgetEditor(context),
                      ),
                    ),
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          if (index == 2) {
                            return const _BudgetSectionDivider();
                          }

                          final int categoryIndex = index > 2
                              ? index - 1
                              : index;
                          return BudgetCategoryCard(
                            data: categories[categoryIndex],
                            todayProgress: todayProgress,
                          );
                        },
                        childCount: categories.length > 2
                            ? categories.length + 1
                            : categories.length,
                      ),
                    ),
                    const SliverToBoxAdapter(child: DemoDataBanner()),
                    const SliverToBoxAdapter(child: SizedBox(height: 156)),
                  ],
                );
              },
        ),
      ),
    );
  }
}

class BudgetHeader extends StatelessWidget {
  const BudgetHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Ngân sách',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _budgetText,
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const _BudgetScopePill(),
          const SizedBox(width: 10),
          _BudgetIconPill(
            icons: const <IconData>[
              Icons.more_horiz_rounded,
              Icons.question_mark_rounded,
            ],
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class BudgetTimeTab extends StatelessWidget {
  const BudgetTimeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Tháng này',
            style: TextStyle(
              color: _budgetText,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          SizedBox(height: 9),
          SizedBox(width: 58, child: Divider(color: _budgetText, height: 2)),
          Divider(color: _budgetDivider, height: 22),
        ],
      ),
    );
  }
}

class BudgetOverviewCard extends StatelessWidget {
  const BudgetOverviewCard({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.availableAmount,
    required this.progress,
    required this.daysLeft,
    required this.isLoading,
    required this.onCreateBudget,
  });

  final double totalBudget;
  final double totalSpent;
  final double availableAmount;
  final double progress;
  final int daysLeft;
  final bool isLoading;
  final VoidCallback onCreateBudget;

  @override
  Widget build(BuildContext context) {
    final bool isOverBudget = availableAmount < 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      decoration: BoxDecoration(
        color: _budgetCard,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const CircleAvatar(
                radius: 18,
                backgroundColor: _budgetCardSoft,
                child: Icon(Icons.public_rounded, color: _budgetText, size: 19),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tất cả các nhóm',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _budgetText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              if (isLoading) ...<Widget>[
                const SizedBox(width: 12),
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    color: _budgetGreen,
                    strokeWidth: 2,
                  ),
                ),
              ],
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded, color: _budgetTextMuted),
            ],
          ),
          const SizedBox(height: 20),
          BudgetArcProgress(
            progress: progress,
            label: 'Số tiền bạn có thể chi',
            value: _formatMoney(availableAmount.abs()),
            valueColor: isOverBudget ? _budgetRed : _budgetGreen,
          ),
          const SizedBox(height: 20),
          BudgetStatsRow(
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            daysLeft: daysLeft,
          ),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: FilledButton(
              onPressed: onCreateBudget,
              style: FilledButton.styleFrom(
                backgroundColor: _budgetGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(
                totalBudget > 0 ? 'Cập nhật Ngân sách' : 'Tạo Ngân sách',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetArcProgress extends StatelessWidget {
  const BudgetArcProgress({
    super.key,
    required this.progress,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  final double progress;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 190,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned.fill(
            child: CustomPaint(painter: _BudgetArcPainter(progress: progress)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _budgetTextMuted,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: valueColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetStatsRow extends StatelessWidget {
  const BudgetStatsRow({
    super.key,
    required this.totalBudget,
    required this.totalSpent,
    required this.daysLeft,
  });

  final double totalBudget;
  final double totalSpent;
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _BudgetStatItem(
            value: _formatCompactMoney(totalBudget),
            label: 'Tổng ngân sách',
          ),
        ),
        const _BudgetVerticalDivider(),
        Expanded(
          child: _BudgetStatItem(
            value: _formatCompactMoney(totalSpent),
            label: 'Tổng đã chi',
          ),
        ),
        const _BudgetVerticalDivider(),
        Expanded(
          child: _BudgetStatItem(
            value: '$daysLeft ngày',
            label: 'Đến cuối tháng',
          ),
        ),
      ],
    );
  }
}

class BudgetCategoryCard extends StatelessWidget {
  const BudgetCategoryCard({
    super.key,
    required this.data,
    required this.todayProgress,
  });

  final BudgetCategoryData data;
  final double todayProgress;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _budgetCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 24,
                backgroundColor: data.color.withValues(alpha: 0.16),
                child: Icon(data.icon, color: data.color, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _budgetText,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    if (data.showInfoIcon) ...<Widget>[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.help_outline_rounded,
                        color: _budgetTextMuted,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 132),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatMoney(data.budgetAmount),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _budgetText,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              data.remainingAmount >= 0
                  ? 'Còn lại ${_formatMoney(data.remainingAmount)}'
                  : 'Vượt ${_formatMoney(data.remainingAmount.abs())}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: data.remainingAmount >= 0
                    ? _budgetTextMuted
                    : _budgetRed,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          BudgetCategoryProgressBar(
            progress: data.progress,
            todayProgress: todayProgress,
          ),
        ],
      ),
    );
  }
}

class BudgetCategoryProgressBar extends StatelessWidget {
  const BudgetCategoryProgressBar({
    super.key,
    required this.progress,
    required this.todayProgress,
  });

  final double progress;
  final double todayProgress;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double barWidth = constraints.maxWidth;
          final double markerLeft = (barWidth * todayProgress.clamp(0.0, 1.0))
              .clamp(0.0, math.max(0, barWidth - 42));

          return Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              Positioned(
                left: 0,
                right: 0,
                top: 6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: _budgetCardSoft,
                    color: _budgetGreen,
                  ),
                ),
              ),
              Positioned(
                left: markerLeft,
                top: 0,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: 2,
                      height: 20,
                      color: Colors.white.withValues(alpha: 0.82),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Hôm nay',
                      style: TextStyle(
                        color: _budgetTextMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class DemoDataBanner extends StatelessWidget {
  const DemoDataBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _budgetBlue,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          const Expanded(
            child: Text(
              'Dữ liệu mẫu - không phải là tài chính thật của bạn. Tắt đi để bắt đầu sử dụng MoneyLover.',
              style: TextStyle(
                color: Colors.white,
                height: 1.35,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              backgroundColor: _budgetBlueSoft,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text(
              'Tắt',
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
        ],
      ),
    );
  }
}

class BudgetCategoryData {
  const BudgetCategoryData({
    required this.name,
    required this.budgetAmount,
    required this.spentAmount,
    required this.icon,
    required this.color,
    this.showInfoIcon = false,
  });

  final String name;
  final double budgetAmount;
  final double spentAmount;
  final IconData icon;
  final Color color;
  final bool showInfoIcon;

  double get remainingAmount => budgetAmount - spentAmount;
  double get progress {
    if (budgetAmount <= 0) {
      return spentAmount > 0 ? 1 : 0;
    }
    return (spentAmount / budgetAmount).clamp(0.0, 1.0);
  }
}

class _BudgetArcPainter extends CustomPainter {
  const _BudgetArcPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final double strokeWidth = 16;
    final Offset center = Offset(size.width / 2, size.height * 0.86);
    final double radius = math.min(size.width * 0.38, size.height * 0.70);
    final Rect rect = Rect.fromCircle(center: center, radius: radius);
    const double startAngle = math.pi;
    const double sweepAngle = math.pi;
    final Paint backgroundPaint = Paint()
      ..color = _budgetCardSoft
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    final Paint progressPaint = Paint()
      ..color = _budgetGreen
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, startAngle, sweepAngle, false, backgroundPaint);
    canvas.drawArc(
      rect,
      startAngle,
      sweepAngle * progress.clamp(0.0, 1.0),
      false,
      progressPaint,
    );

    final double dotAngle = startAngle + sweepAngle * progress.clamp(0.0, 1.0);
    final Offset dotCenter = Offset(
      center.dx + radius * math.cos(dotAngle),
      center.dy + radius * math.sin(dotAngle),
    );
    canvas.drawCircle(dotCenter, 9, Paint()..color = _budgetGreen);
    canvas.drawCircle(dotCenter, 4, Paint()..color = _budgetBackground);
  }

  @override
  bool shouldRepaint(covariant _BudgetArcPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

class _BudgetScopePill extends StatelessWidget {
  const _BudgetScopePill();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _budgetCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.public_rounded, color: _budgetText, size: 19),
              SizedBox(width: 6),
              Icon(Icons.keyboard_arrow_down_rounded, color: _budgetTextMuted),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetIconPill extends StatelessWidget {
  const _BudgetIconPill({required this.icons, required this.onPressed});

  final List<IconData> icons;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _budgetCard,
      borderRadius: BorderRadius.circular(999),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: icons.map((IconData icon) {
          return InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              width: 40,
              height: 46,
              child: Icon(icon, color: _budgetText, size: 21),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _BudgetStatItem extends StatelessWidget {
  const _BudgetStatItem({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: _budgetText,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: _budgetTextMuted,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _BudgetVerticalDivider extends StatelessWidget {
  const _BudgetVerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 42,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      color: _budgetDivider,
    );
  }
}

class _BudgetSectionDivider extends StatelessWidget {
  const _BudgetSectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(42, 18, 42, 2),
      child: Divider(color: _budgetDivider),
    );
  }
}

List<BudgetCategoryData> _buildBudgetCategories({
  required Map<String, double> expenseByCategory,
  required double totalBudget,
}) {
  final List<MapEntry<String, double>> entries =
      expenseByCategory.entries.toList()..sort(
        (MapEntry<String, double> a, MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );

  if (entries.isEmpty) {
    return <BudgetCategoryData>[
      BudgetCategoryData(
        name: 'Tất cả các nhóm',
        budgetAmount: totalBudget,
        spentAmount: 0,
        icon: Icons.public_rounded,
        color: _budgetGreen,
      ),
    ];
  }

  final double totalSpent = entries.fold<double>(
    0,
    (double sum, MapEntry<String, double> entry) => sum + entry.value,
  );
  final List<MapEntry<String, double>> topEntries = entries.take(2).toList();
  final List<MapEntry<String, double>> remainingEntries = entries
      .skip(2)
      .toList();
  final List<BudgetCategoryData> categories = <BudgetCategoryData>[];
  double allocatedTopBudget = 0;

  for (final MapEntry<String, double> entry in topEntries) {
    final double allocatedBudget = _allocateCategoryBudget(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      categorySpent: entry.value,
    );
    allocatedTopBudget += allocatedBudget;
    categories.add(
      BudgetCategoryData(
        name: entry.key,
        budgetAmount: allocatedBudget,
        spentAmount: entry.value,
        icon: AppConstants.categoryIcon(entry.key, AppConstants.expenseType),
        color: _categoryColor(entry.key),
      ),
    );
  }

  if (remainingEntries.isNotEmpty) {
    final double remainingSpent = remainingEntries.fold<double>(
      0,
      (double sum, MapEntry<String, double> entry) => sum + entry.value,
    );
    final double remainingBudget = totalBudget <= 0
        ? remainingSpent
        : math.max(0, totalBudget - allocatedTopBudget);
    categories.add(
      BudgetCategoryData(
        name: 'Các nhóm còn lại',
        budgetAmount: remainingBudget,
        spentAmount: remainingSpent,
        icon: Icons.category_rounded,
        color: _budgetTextMuted,
        showInfoIcon: true,
      ),
    );
  }

  return categories;
}

double _allocateCategoryBudget({
  required double totalBudget,
  required double totalSpent,
  required double categorySpent,
}) {
  if (totalBudget <= 0 || totalSpent <= 0) {
    return categorySpent;
  }
  return totalBudget * categorySpent / totalSpent;
}

int _daysLeftInMonth(DateTime selectedMonth) {
  final DateTime now = DateTime.now();
  final DateTime monthEnd = DateTime(
    selectedMonth.year,
    selectedMonth.month + 1,
    0,
  );

  if (selectedMonth.year != now.year || selectedMonth.month != now.month) {
    return monthEnd.isBefore(now) ? 0 : monthEnd.day;
  }

  return math.max(0, monthEnd.day - now.day);
}

double _monthElapsedProgress(DateTime selectedMonth) {
  final DateTime now = DateTime.now();
  final int daysInMonth = DateTime(
    selectedMonth.year,
    selectedMonth.month + 1,
    0,
  ).day;

  if (selectedMonth.year != now.year || selectedMonth.month != now.month) {
    return selectedMonth.isBefore(DateTime(now.year, now.month)) ? 1 : 0;
  }

  return (now.day / daysInMonth).clamp(0.0, 1.0);
}

String _formatMoney(num amount) {
  return _budgetMoneyFormat.format(amount).trim();
}

String _formatCompactMoney(num amount) {
  final double value = amount.toDouble();
  final double absolute = value.abs();

  if (absolute >= 1000000000) {
    return '${_trimCompact(value / 1000000000)} T';
  }
  if (absolute >= 1000000) {
    return '${_trimCompact(value / 1000000)} M';
  }
  if (absolute >= 1000) {
    return '${_trimCompact(value / 1000)} K';
  }
  return value.toStringAsFixed(0);
}

String _trimCompact(double value) {
  final String text = value.toStringAsFixed(value.abs() >= 10 ? 0 : 1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

Color _categoryColor(String category) {
  switch (category) {
    case 'Ăn uống':
      return const Color(0xFFF59E0B);
    case 'Đi lại':
      return const Color(0xFF22D3EE);
    case 'Mua sắm':
      return const Color(0xFFA78BFA);
    case 'Học tập':
      return const Color(0xFF38BDF8);
    case 'Giải trí':
      return const Color(0xFFF472B6);
    case 'Hóa đơn':
      return const Color(0xFFCBD5E1);
    case 'Sức khỏe':
      return const Color(0xFFFB7185);
    default:
      return _budgetGreen;
  }
}
