import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';

const Color _overviewBackground = Color(0xFF000000);
const Color _overviewCard = Color(0xFF1C1C1E);
const Color _overviewCardSoft = Color(0xFF2C2C2E);
const Color _overviewText = Color(0xFFFFFFFF);
const Color _overviewTextMuted = Color(0xFFA1A1AA);
const Color _overviewDivider = Color(0xFF34343A);
const Color _overviewGreen = Color(0xFF34D399);
const Color _overviewBlue = Color(0xFF60A5FA);
const Color _overviewRed = Color(0xFFFB7185);

class OverviewHeader extends StatelessWidget {
  const OverviewHeader({
    super.key,
    required this.balance,
    required this.balanceVisible,
    required this.onToggleBalanceVisibility,
    required this.onSearchPressed,
    this.onNotificationPressed,
  });

  final double balance;
  final bool balanceVisible;
  final VoidCallback onToggleBalanceVisibility;
  final VoidCallback onSearchPressed;
  final VoidCallback? onNotificationPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Tổng số dư',
                  style: TextStyle(
                    color: _overviewTextMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        balanceVisible
                            ? CurrencyFormatter.format(balance)
                            : '********',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _overviewText,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: onToggleBalanceVisibility,
                      icon: Icon(
                        balanceVisible
                            ? Icons.visibility_rounded
                            : Icons.visibility_off_rounded,
                        color: _overviewTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: <Widget>[
              _HeaderIconButton(
                icon: Icons.search_rounded,
                onPressed: onSearchPressed,
              ),
              const SizedBox(width: 10),
              _HeaderIconButton(
                icon: Icons.notifications_none_rounded,
                onPressed: onNotificationPressed ?? () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _overviewCard,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: _overviewText, size: 23),
        ),
      ),
    );
  }
}

class WalletSection extends StatelessWidget {
  const WalletSection({
    super.key,
    required this.balance,
    required this.monthIncome,
    required this.monthExpense,
    required this.onViewAll,
  });

  final double balance;
  final double monthIncome;
  final double monthExpense;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return WalletCard(
      onViewAll: onViewAll,
      items: <WalletItemData>[
        WalletItemData(
          name: 'Số dư hiện tại',
          amount: balance,
          icon: Icons.account_balance_wallet_rounded,
          color: _overviewGreen,
        ),
        WalletItemData(
          name: 'Thu nhập tháng này',
          amount: monthIncome,
          icon: Icons.trending_up_rounded,
          color: _overviewBlue,
        ),
        WalletItemData(
          name: 'Chi tiêu tháng này',
          amount: -monthExpense,
          icon: Icons.shopping_bag_rounded,
          color: _overviewRed,
        ),
      ],
    );
  }
}

class WalletCard extends StatelessWidget {
  const WalletCard({super.key, required this.items, required this.onViewAll});

  final List<WalletItemData> items;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _overviewCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Ví của tôi',
                  style: TextStyle(
                    color: _overviewText,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: _overviewGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (int index = 0; index < items.length; index++) ...<Widget>[
            WalletItem(item: items[index]),
            if (index < items.length - 1)
              const Divider(height: 28, color: _overviewDivider),
          ],
        ],
      ),
    );
  }
}

class WalletItem extends StatelessWidget {
  const WalletItem({super.key, required this.item});

  final WalletItemData item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 24,
          backgroundColor: item.color.withValues(alpha: 0.16),
          child: Icon(item.icon, color: item.color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            item.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _overviewText,
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              CurrencyFormatter.format(item.amount),
              textAlign: TextAlign.right,
              style: TextStyle(
                color: item.amount < 0 ? _overviewRed : _overviewText,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class WalletItemData {
  const WalletItemData({
    required this.name,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String name;
  final double amount;
  final IconData icon;
  final Color color;
}

class MonthlyReportSection extends StatefulWidget {
  const MonthlyReportSection({
    super.key,
    required this.selectedMonth,
    required this.transactions,
    required this.monthIncome,
    required this.monthExpense,
    required this.onViewReport,
  });

  final DateTime selectedMonth;
  final List<TransactionModel> transactions;
  final double monthIncome;
  final double monthExpense;
  final VoidCallback onViewReport;

  @override
  State<MonthlyReportSection> createState() => _MonthlyReportSectionState();
}

class _MonthlyReportSectionState extends State<MonthlyReportSection> {
  int _reportIndex = 0;

  void _changeReport(int value) {
    setState(() {
      _reportIndex = value % 2;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          ReportHeader(
            title: 'Báo cáo tháng này',
            action: 'Xem báo cáo',
            onPressed: widget.onViewReport,
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            child: _reportIndex == 0
                ? TrendReportCard(
                    key: const ValueKey<String>('trend-report'),
                    selectedMonth: widget.selectedMonth,
                    transactions: widget.transactions,
                    monthIncome: widget.monthIncome,
                    monthExpense: widget.monthExpense,
                    onPrevious: () => _changeReport(1),
                    onNext: () => _changeReport(1),
                  )
                : ExpenseReportCard(
                    key: const ValueKey<String>('expense-report'),
                    selectedMonth: widget.selectedMonth,
                    transactions: widget.transactions,
                    monthExpense: widget.monthExpense,
                    onPrevious: () => _changeReport(0),
                    onNext: () => _changeReport(0),
                  ),
          ),
        ],
      ),
    );
  }
}

class ReportHeader extends StatelessWidget {
  const ReportHeader({
    super.key,
    required this.title,
    required this.action,
    this.onPressed,
  });

  final String title;
  final String action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: _overviewText,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        TextButton(
          onPressed: onPressed ?? () {},
          child: Text(
            action,
            style: const TextStyle(
              color: _overviewGreen,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }
}

class ReportCard extends StatelessWidget {
  const ReportCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 440),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _overviewCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

enum ReportMetricType { expense, income }

class TrendReportCard extends StatefulWidget {
  const TrendReportCard({
    super.key,
    required this.selectedMonth,
    required this.transactions,
    required this.monthIncome,
    required this.monthExpense,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime selectedMonth;
  final List<TransactionModel> transactions;
  final double monthIncome;
  final double monthExpense;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  State<TrendReportCard> createState() => _TrendReportCardState();
}

class _TrendReportCardState extends State<TrendReportCard> {
  ReportMetricType _selectedReportType = ReportMetricType.expense;

  @override
  Widget build(BuildContext context) {
    final bool showingExpense = _selectedReportType == ReportMetricType.expense;
    final Color activeColor = showingExpense ? _overviewRed : _overviewBlue;
    final double activeTotal = showingExpense
        ? widget.monthExpense
        : widget.monthIncome;
    final _TrendData trendData = _buildTrendData(
      widget.transactions,
      widget.selectedMonth,
      showingExpense ? AppConstants.expenseType : AppConstants.incomeType,
    );
    final double combined = widget.monthIncome + widget.monthExpense;
    final double activeRatio = combined <= 0 ? 0 : activeTotal / combined;

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: ReportMetricSelector(
                  label: 'Tổng đã chi',
                  value: CurrencyFormatter.format(widget.monthExpense),
                  color: _overviewRed,
                  active: showingExpense,
                  onTap: () {
                    setState(() {
                      _selectedReportType = ReportMetricType.expense;
                    });
                  },
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: ReportMetricSelector(
                  label: 'Tổng thu',
                  value: CurrencyFormatter.format(widget.monthIncome),
                  color: _overviewBlue,
                  active: !showingExpense,
                  onTap: () {
                    setState(() {
                      _selectedReportType = ReportMetricType.income;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 5,
              value: activeRatio.clamp(0, 1),
              color: activeColor,
              backgroundColor: _overviewDivider,
            ),
          ),
          const SizedBox(height: 22),
          Stack(
            children: <Widget>[
              SizedBox(
                height: 190,
                width: double.infinity,
                child: SimpleLineChart(
                  currentValues: trendData.currentValues,
                  averageValues: trendData.averageValues,
                  maxY: trendData.maxY,
                  lineColor: activeColor,
                  startLabel: DateFormat('dd/MM').format(widget.selectedMonth),
                  endLabel: DateFormat('dd/MM').format(
                    DateTime(
                      widget.selectedMonth.year,
                      widget.selectedMonth.month + 1,
                      0,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 10,
                right: 8,
                child: _ChartTooltip(
                  date: trendData.tooltipDate,
                  currentValue: trendData.currentTooltipValue,
                  averageValue: trendData.averageTooltipValue,
                  activeColor: activeColor,
                  currentLabel: showingExpense ? 'Chi tiêu' : 'Thu nhập',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ReportLegend(
            items: <ReportLegendItem>[
              ReportLegendItem(color: activeColor, label: 'Tháng này'),
              const ReportLegendItem(
                color: _overviewTextMuted,
                label: 'Trung bình 3 tháng trước',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ReportNavigation(
            title: 'Báo cáo xu hướng',
            activeIndex: 0,
            onPrevious: widget.onPrevious,
            onNext: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class ExpenseReportCard extends StatefulWidget {
  const ExpenseReportCard({
    super.key,
    required this.selectedMonth,
    required this.transactions,
    required this.monthExpense,
    required this.onPrevious,
    required this.onNext,
  });

  final DateTime selectedMonth;
  final List<TransactionModel> transactions;
  final double monthExpense;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  State<ExpenseReportCard> createState() => _ExpenseReportCardState();
}

class _ExpenseReportCardState extends State<ExpenseReportCard> {
  int _selectedPeriod = 0;

  @override
  Widget build(BuildContext context) {
    final _ExpensePeriodData periodData = _selectedPeriod == 0
        ? _buildWeeklyExpenseData(widget.transactions)
        : _buildMonthlyExpenseData(widget.transactions, widget.selectedMonth);
    final double percentChange = _calculateChangePercent(
      periodData.current,
      periodData.previous,
    );

    return ReportCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SegmentedToggle(
            labels: const <String>['Tuần', 'Tháng'],
            selectedIndex: _selectedPeriod,
            onChanged: (int value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
          ),
          const SizedBox(height: 22),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              CurrencyFormatter.format(periodData.current),
              style: const TextStyle(
                color: _overviewText,
                fontSize: 32,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _selectedPeriod == 0
                      ? 'Tổng đã chi tuần này'
                      : 'Tổng đã chi tháng này',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _overviewTextMuted,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                percentChange <= 0
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: percentChange <= 0 ? _overviewGreen : _overviewRed,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                '${percentChange.abs().toStringAsFixed(0)}%',
                style: TextStyle(
                  color: percentChange <= 0 ? _overviewGreen : _overviewRed,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 230,
            child: SimpleBarChart(
              previousValue: periodData.previous,
              currentValue: periodData.current,
              maxY: periodData.maxY,
              previousLabel: periodData.previousLabel,
              currentLabel: periodData.currentLabel,
            ),
          ),
          const SizedBox(height: 20),
          _ReportNavigation(
            title: 'Báo cáo chi tiêu',
            activeIndex: 1,
            onPrevious: widget.onPrevious,
            onNext: widget.onNext,
          ),
        ],
      ),
    );
  }
}

class ReportMetricSelector extends StatelessWidget {
  const ReportMetricSelector({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final String value;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: active ? 1 : 0.58,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _overviewTextMuted,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: active ? 46 : 0,
                height: 3,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChartTooltip extends StatelessWidget {
  const _ChartTooltip({
    required this.date,
    required this.currentValue,
    required this.averageValue,
    required this.activeColor,
    required this.currentLabel,
  });

  final DateTime date;
  final double currentValue;
  final double averageValue;
  final Color activeColor;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF101014),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _overviewDivider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            DateFormat('dd/MM/yyyy').format(date),
            style: const TextStyle(
              color: _overviewText,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$currentLabel: ${_formatCompactMoney(currentValue)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: activeColor, fontSize: 11),
          ),
          Text(
            'TB 3 tháng: ${_formatCompactMoney(averageValue)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: _overviewTextMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class ReportLegend extends StatelessWidget {
  const ReportLegend({super.key, required this.items});

  final List<ReportLegendItem> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        for (final ReportLegendItem item in items)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                item.label,
                style: const TextStyle(
                  color: _overviewTextMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        const Icon(
          Icons.help_outline_rounded,
          color: _overviewTextMuted,
          size: 16,
        ),
      ],
    );
  }
}

class ReportLegendItem {
  const ReportLegendItem({required this.color, required this.label});

  final Color color;
  final String label;
}

class _ReportNavigation extends StatelessWidget {
  const _ReportNavigation({
    required this.title,
    required this.activeIndex,
    required this.onPrevious,
    required this.onNext,
  });

  final String title;
  final int activeIndex;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            IconButton(
              onPressed: onPrevious,
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: _overviewTextMuted,
              ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _overviewGreen,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              onPressed: onNext,
              icon: const Icon(
                Icons.chevron_right_rounded,
                color: _overviewTextMuted,
              ),
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _IndicatorDot(active: activeIndex == 0),
            const SizedBox(width: 6),
            _IndicatorDot(active: activeIndex == 1),
          ],
        ),
      ],
    );
  }
}

class _IndicatorDot extends StatelessWidget {
  const _IndicatorDot({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: active ? 18 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: active ? _overviewGreen : _overviewDivider,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }
}

class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF111113),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: <Widget>[
          for (int index = 0; index < labels.length; index++)
            Expanded(
              child: GestureDetector(
                onTap: () => onChanged(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: index == selectedIndex
                        ? _overviewCardSoft
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    labels[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: index == selectedIndex
                          ? _overviewText
                          : _overviewTextMuted,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class SimpleLineChart extends StatelessWidget {
  const SimpleLineChart({
    super.key,
    required this.currentValues,
    required this.averageValues,
    required this.maxY,
    required this.lineColor,
    required this.startLabel,
    required this.endLabel,
  });

  final List<double> currentValues;
  final List<double> averageValues;
  final double maxY;
  final Color lineColor;
  final String startLabel;
  final String endLabel;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SimpleLineChartPainter(
        currentValues: currentValues,
        averageValues: averageValues,
        maxY: maxY,
        lineColor: lineColor,
        startLabel: startLabel,
        endLabel: endLabel,
      ),
    );
  }
}

class _SimpleLineChartPainter extends CustomPainter {
  const _SimpleLineChartPainter({
    required this.currentValues,
    required this.averageValues,
    required this.maxY,
    required this.lineColor,
    required this.startLabel,
    required this.endLabel,
  });

  final List<double> currentValues;
  final List<double> averageValues;
  final double maxY;
  final Color lineColor;
  final String startLabel;
  final String endLabel;

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 42;
    const double top = 8;
    const double right = 8;
    const double bottom = 28;
    final double chartWidth = size.width - left - right;
    final double chartHeight = size.height - top - bottom;
    final Paint gridPaint = Paint()
      ..color = _overviewDivider.withValues(alpha: 0.62)
      ..strokeWidth = 1;

    for (int index = 0; index <= 5; index++) {
      final double y = top + chartHeight * index / 5;
      canvas.drawLine(
        Offset(left, y),
        Offset(size.width - right, y),
        gridPaint,
      );
      _paintText(
        canvas,
        _formatAxisMoney(maxY * (5 - index) / 5),
        Offset(0, y - 8),
        color: _overviewTextMuted,
        fontSize: 10,
      );
    }

    _drawLine(
      canvas,
      values: averageValues,
      color: _overviewTextMuted,
      left: left,
      top: top,
      width: chartWidth,
      height: chartHeight,
      strokeWidth: 2,
    );
    _drawLine(
      canvas,
      values: currentValues,
      color: lineColor,
      left: left,
      top: top,
      width: chartWidth,
      height: chartHeight,
      strokeWidth: 3,
    );

    _paintText(
      canvas,
      startLabel,
      Offset(left, size.height - 18),
      color: _overviewTextMuted,
      fontSize: 10,
    );
    _paintText(
      canvas,
      endLabel,
      Offset(size.width - 48, size.height - 18),
      color: _overviewTextMuted,
      fontSize: 10,
    );
  }

  void _drawLine(
    Canvas canvas, {
    required List<double> values,
    required Color color,
    required double left,
    required double top,
    required double width,
    required double height,
    required double strokeWidth,
  }) {
    if (values.isEmpty) {
      return;
    }

    final Path path = Path();
    for (int index = 0; index < values.length; index++) {
      final double x =
          left + (values.length == 1 ? 0 : width * index / (values.length - 1));
      final double y = top + height * (1 - (values[index] / maxY).clamp(0, 1));
      if (index == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint linePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = strokeWidth;
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SimpleLineChartPainter oldDelegate) {
    return oldDelegate.currentValues != currentValues ||
        oldDelegate.averageValues != averageValues ||
        oldDelegate.maxY != maxY ||
        oldDelegate.lineColor != lineColor;
  }
}

class SimpleBarChart extends StatelessWidget {
  const SimpleBarChart({
    super.key,
    required this.previousValue,
    required this.currentValue,
    required this.maxY,
    required this.previousLabel,
    required this.currentLabel,
  });

  final double previousValue;
  final double currentValue;
  final double maxY;
  final String previousLabel;
  final String currentLabel;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _SimpleBarChartPainter(
        previousValue: previousValue,
        currentValue: currentValue,
        maxY: maxY,
        previousLabel: previousLabel,
        currentLabel: currentLabel,
      ),
    );
  }
}

class _SimpleBarChartPainter extends CustomPainter {
  const _SimpleBarChartPainter({
    required this.previousValue,
    required this.currentValue,
    required this.maxY,
    required this.previousLabel,
    required this.currentLabel,
  });

  final double previousValue;
  final double currentValue;
  final double maxY;
  final String previousLabel;
  final String currentLabel;

  @override
  void paint(Canvas canvas, Size size) {
    const double left = 8;
    const double right = 44;
    const double bottom = 34;
    const double top = 16;
    final double chartHeight = size.height - top - bottom;
    final double chartRight = size.width - right;
    final double baseY = top + chartHeight;
    final Paint axisPaint = Paint()
      ..color = _overviewDivider
      ..strokeWidth = 1.2;

    canvas.drawLine(Offset(left, baseY), Offset(chartRight, baseY), axisPaint);
    _paintText(
      canvas,
      '0',
      Offset(chartRight + 10, baseY - 8),
      color: _overviewTextMuted,
      fontSize: 11,
    );
    _paintText(
      canvas,
      _formatAxisMoney(maxY),
      Offset(chartRight + 10, top - 4),
      color: _overviewTextMuted,
      fontSize: 11,
    );

    final double availableWidth = chartRight - left;
    final double barWidth = math.min(72, availableWidth / 4);
    final double firstX = left + availableWidth * 0.25 - barWidth / 2;
    final double secondX = left + availableWidth * 0.70 - barWidth / 2;

    _drawBar(
      canvas,
      Rect.fromLTWH(
        firstX,
        baseY - chartHeight * (previousValue / maxY).clamp(0, 1),
        barWidth,
        chartHeight * (previousValue / maxY).clamp(0, 1),
      ),
      _overviewRed.withValues(alpha: 0.48),
    );
    _drawBar(
      canvas,
      Rect.fromLTWH(
        secondX,
        baseY - chartHeight * (currentValue / maxY).clamp(0, 1),
        barWidth,
        chartHeight * (currentValue / maxY).clamp(0, 1),
      ),
      _overviewRed,
    );

    _paintText(
      canvas,
      previousLabel,
      Offset(firstX - 8, size.height - 20),
      color: _overviewTextMuted,
      fontSize: 11,
    );
    _paintText(
      canvas,
      currentLabel,
      Offset(secondX - 8, size.height - 20),
      color: _overviewText,
      fontSize: 11,
    );
  }

  void _drawBar(Canvas canvas, Rect rect, Color color) {
    final RRect rounded = RRect.fromRectAndRadius(
      rect,
      const Radius.circular(14),
    );
    canvas.drawRRect(rounded, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _SimpleBarChartPainter oldDelegate) {
    return oldDelegate.previousValue != previousValue ||
        oldDelegate.currentValue != currentValue ||
        oldDelegate.maxY != maxY;
  }
}

class TopSpendingSection extends StatefulWidget {
  const TopSpendingSection({
    super.key,
    required this.selectedMonth,
    required this.transactions,
    required this.onViewDetail,
  });

  final DateTime selectedMonth;
  final List<TransactionModel> transactions;
  final VoidCallback onViewDetail;

  @override
  State<TopSpendingSection> createState() => _TopSpendingSectionState();
}

class _TopSpendingSectionState extends State<TopSpendingSection> {
  int _selectedPeriod = 0;

  @override
  Widget build(BuildContext context) {
    final List<TopSpendingData> items = _buildTopSpendingData(
      transactions: widget.transactions,
      selectedMonth: widget.selectedMonth,
      weekly: _selectedPeriod == 0,
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Chi tiêu nhiều nhất',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _overviewText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: widget.onViewDetail,
                child: const Text(
                  'Xem chi tiết',
                  style: TextStyle(
                    color: _overviewGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TopSpendingCard(
            selectedPeriod: _selectedPeriod,
            onPeriodChanged: (int value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            items: items,
          ),
        ],
      ),
    );
  }
}

class TopSpendingCard extends StatelessWidget {
  const TopSpendingCard({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
    required this.items,
  });

  final int selectedPeriod;
  final ValueChanged<int> onPeriodChanged;
  final List<TopSpendingData> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _overviewCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          SpendingPeriodToggle(
            selectedIndex: selectedPeriod,
            onChanged: onPeriodChanged,
          ),
          const SizedBox(height: 22),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'Chưa có dữ liệu chi tiêu cho kỳ này.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _overviewTextMuted),
              ),
            )
          else
            for (int index = 0; index < items.length; index++) ...<Widget>[
              TopSpendingItem(item: items[index]),
              if (index < items.length - 1) const SizedBox(height: 22),
            ],
        ],
      ),
    );
  }
}

class SpendingPeriodToggle extends StatelessWidget {
  const SpendingPeriodToggle({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedToggle(
      labels: const <String>['Tuần', 'Tháng'],
      selectedIndex: selectedIndex,
      onChanged: onChanged,
    );
  }
}

class TopSpendingItem extends StatelessWidget {
  const TopSpendingItem({super.key, required this.item});

  final TopSpendingData item;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          radius: 26,
          backgroundColor: item.color.withValues(alpha: 0.16),
          child: Icon(item.icon, color: item.color, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _overviewText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                CurrencyFormatter.format(item.amount),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _overviewTextMuted,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          '${item.percent.round()}%',
          style: const TextStyle(
            color: _overviewRed,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class TopSpendingData {
  const TopSpendingData({
    required this.category,
    required this.amount,
    required this.percent,
    required this.icon,
    required this.color,
  });

  final String category;
  final double amount;
  final double percent;
  final IconData icon;
  final Color color;
}

class RecentTransactionsSection extends StatelessWidget {
  const RecentTransactionsSection({
    super.key,
    required this.transactions,
    required this.onViewAll,
  });

  final List<TransactionModel> transactions;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Giao dịch gần đây',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _overviewText,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'Xem tất cả',
                  style: TextStyle(
                    color: _overviewGreen,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          RecentTransactionsCard(transactions: transactions.take(3).toList()),
        ],
      ),
    );
  }
}

class RecentTransactionsCard extends StatelessWidget {
  const RecentTransactionsCard({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _overviewCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: transactions.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 28),
              child: Text(
                'Chưa có giao dịch gần đây.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _overviewTextMuted),
              ),
            )
          : Column(
              children: <Widget>[
                for (int index = 0; index < transactions.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == transactions.length - 1 ? 0 : 22,
                    ),
                    child: RecentTransactionItem(
                      transaction: transactions[index],
                    ),
                  ),
              ],
            ),
    );
  }
}

class RecentTransactionItem extends StatelessWidget {
  const RecentTransactionItem({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == AppConstants.incomeType;
    final Color amountColor = isIncome ? _overviewBlue : _overviewRed;
    final String amountPrefix = isIncome ? '+' : '-';

    return Row(
      children: <Widget>[
        Stack(
          clipBehavior: Clip.none,
          children: <Widget>[
            CircleAvatar(
              radius: 28,
              backgroundColor: amountColor.withValues(alpha: 0.16),
              child: Icon(
                AppConstants.categoryIcon(
                  transaction.category,
                  transaction.type,
                ),
                color: amountColor,
                size: 24,
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: _overviewGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: _overviewCard, width: 3),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_rounded,
                  color: Colors.black,
                  size: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                transaction.category,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _overviewText,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DateFormat(
                  "EEEE, dd 'tháng' M yyyy",
                  'vi_VN',
                ).format(transaction.date),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: _overviewTextMuted,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              '$amountPrefix${CurrencyFormatter.format(transaction.amount)}',
              textAlign: TextAlign.right,
              style: TextStyle(
                color: amountColor,
                fontSize: 17,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OverviewDarkScaffold extends StatelessWidget {
  const OverviewDarkScaffold({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(color: _overviewBackground, child: child);
  }
}

_TrendData _buildTrendData(
  List<TransactionModel> transactions,
  DateTime selectedMonth,
  String transactionType,
) {
  final int daysInMonth = DateTime(
    selectedMonth.year,
    selectedMonth.month + 1,
    0,
  ).day;
  final List<double> current = List<double>.filled(daysInMonth, 0);
  final List<double> average = List<double>.filled(daysInMonth, 0);

  for (final TransactionModel transaction in transactions) {
    if (transaction.type != transactionType) {
      continue;
    }
    if (transaction.date.year == selectedMonth.year &&
        transaction.date.month == selectedMonth.month) {
      current[transaction.date.day - 1] += transaction.amount;
    }
  }

  for (int monthOffset = 1; monthOffset <= 3; monthOffset++) {
    final DateTime month = DateTime(
      selectedMonth.year,
      selectedMonth.month - monthOffset,
    );
    for (final TransactionModel transaction in transactions) {
      if (transaction.type != transactionType ||
          transaction.date.year != month.year ||
          transaction.date.month != month.month) {
        continue;
      }
      final int dayIndex = math.min(transaction.date.day, daysInMonth) - 1;
      average[dayIndex] += transaction.amount / 3;
    }
  }

  _accumulate(current);
  _accumulate(average);

  final double maxValue = <double>[
    ...current,
    ...average,
    1000000,
  ].reduce(math.max);
  final double maxY = _niceChartMax(maxValue);
  final int tooltipIndex = math.max(
    0,
    math.min(daysInMonth - 1, DateTime.now().day - 1),
  );

  return _TrendData(
    currentValues: current,
    averageValues: average,
    maxY: maxY,
    tooltipDate: DateTime(
      selectedMonth.year,
      selectedMonth.month,
      tooltipIndex + 1,
    ),
    currentTooltipValue: current[tooltipIndex],
    averageTooltipValue: average[tooltipIndex],
  );
}

void _accumulate(List<double> values) {
  for (int index = 1; index < values.length; index++) {
    values[index] += values[index - 1];
  }
}

class _TrendData {
  const _TrendData({
    required this.currentValues,
    required this.averageValues,
    required this.maxY,
    required this.tooltipDate,
    required this.currentTooltipValue,
    required this.averageTooltipValue,
  });

  final List<double> currentValues;
  final List<double> averageValues;
  final double maxY;
  final DateTime tooltipDate;
  final double currentTooltipValue;
  final double averageTooltipValue;
}

_ExpensePeriodData _buildWeeklyExpenseData(
  List<TransactionModel> transactions,
) {
  final DateTime now = DateTime.now();
  final DateTime currentStart = _weekStart(now);
  final DateTime previousStart = currentStart.subtract(const Duration(days: 7));
  final DateTime previousEnd = currentStart.subtract(const Duration(days: 1));
  final double current = _sumExpenseBetween(transactions, currentStart, now);
  final double previous = _sumExpenseBetween(
    transactions,
    previousStart,
    previousEnd,
  );
  return _ExpensePeriodData(
    current: current,
    previous: previous,
    maxY: _niceChartMax(math.max(current, previous)),
    previousLabel: 'Tuần trước',
    currentLabel: 'Tuần này',
  );
}

_ExpensePeriodData _buildMonthlyExpenseData(
  List<TransactionModel> transactions,
  DateTime selectedMonth,
) {
  final DateTime previousMonth = DateTime(
    selectedMonth.year,
    selectedMonth.month - 1,
  );
  final double current = _sumExpenseForMonth(transactions, selectedMonth);
  final double previous = _sumExpenseForMonth(transactions, previousMonth);
  return _ExpensePeriodData(
    current: current,
    previous: previous,
    maxY: _niceChartMax(math.max(current, previous)),
    previousLabel: 'Tháng trước',
    currentLabel: 'Tháng này',
  );
}

class _ExpensePeriodData {
  const _ExpensePeriodData({
    required this.current,
    required this.previous,
    required this.maxY,
    required this.previousLabel,
    required this.currentLabel,
  });

  final double current;
  final double previous;
  final double maxY;
  final String previousLabel;
  final String currentLabel;
}

List<TopSpendingData> _buildTopSpendingData({
  required List<TransactionModel> transactions,
  required DateTime selectedMonth,
  required bool weekly,
}) {
  final DateTime now = DateTime.now();
  final DateTime weekStart = _weekStart(now);
  final Map<String, double> grouped = <String, double>{};

  for (final TransactionModel transaction in transactions) {
    if (transaction.type != AppConstants.expenseType) {
      continue;
    }

    final bool inRange = weekly
        ? !transaction.date.isBefore(weekStart) &&
              !transaction.date.isAfter(now)
        : transaction.date.year == selectedMonth.year &&
              transaction.date.month == selectedMonth.month;

    if (!inRange) {
      continue;
    }

    grouped.update(
      transaction.category,
      (double value) => value + transaction.amount,
      ifAbsent: () => transaction.amount,
    );
  }

  final double total = grouped.values.fold<double>(
    0,
    (double sum, double value) => sum + value,
  );
  final List<MapEntry<String, double>> entries = grouped.entries.toList()
    ..sort(
      (MapEntry<String, double> a, MapEntry<String, double> b) =>
          b.value.compareTo(a.value),
    );

  return entries.take(3).map((MapEntry<String, double> entry) {
    return TopSpendingData(
      category: entry.key,
      amount: entry.value,
      percent: total <= 0 ? 0 : entry.value / total * 100,
      icon: AppConstants.categoryIcon(entry.key, AppConstants.expenseType),
      color: _colorForCategory(entry.key),
    );
  }).toList();
}

DateTime _weekStart(DateTime date) {
  final DateTime day = DateTime(date.year, date.month, date.day);
  return day.subtract(Duration(days: day.weekday - 1));
}

double _sumExpenseBetween(
  List<TransactionModel> transactions,
  DateTime start,
  DateTime end,
) {
  return transactions
      .where(
        (TransactionModel item) =>
            item.type == AppConstants.expenseType &&
            !item.date.isBefore(start) &&
            !item.date.isAfter(DateTime(end.year, end.month, end.day, 23, 59)),
      )
      .fold<double>(
        0,
        (double sum, TransactionModel item) => sum + item.amount,
      );
}

double _sumExpenseForMonth(
  List<TransactionModel> transactions,
  DateTime month,
) {
  return transactions
      .where(
        (TransactionModel item) =>
            item.type == AppConstants.expenseType &&
            item.date.year == month.year &&
            item.date.month == month.month,
      )
      .fold<double>(
        0,
        (double sum, TransactionModel item) => sum + item.amount,
      );
}

double _calculateChangePercent(double current, double previous) {
  if (previous <= 0) {
    return current > 0 ? 100 : 0;
  }
  return (current - previous) / previous * 100;
}

double _niceChartMax(double value) {
  if (value <= 0) {
    return 1000000;
  }
  final double magnitude = math
      .pow(10, value.floor().toString().length - 1)
      .toDouble();
  final double rounded = (value / magnitude).ceil() * magnitude;
  return math.max(rounded, 1000000);
}

String _formatCompactMoney(double value) {
  final double absolute = value.abs();
  if (absolute >= 1000000000) {
    return '${(value / 1000000000).toStringAsFixed(1)}B';
  }
  if (absolute >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(0)}M';
  }
  if (absolute >= 1000) {
    return '${(value / 1000).toStringAsFixed(0)}K';
  }
  return value.toStringAsFixed(0);
}

String _formatAxisMoney(double value) {
  if (value == 0) {
    return '0';
  }
  return _formatCompactMoney(value);
}

void _paintText(
  Canvas canvas,
  String text,
  Offset offset, {
  required Color color,
  required double fontSize,
}) {
  final TextPainter painter = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
    ),
    textDirection: ui.TextDirection.ltr,
  )..layout();
  painter.paint(canvas, offset);
}

Color _colorForCategory(String category) {
  final int index = category.hashCode.abs() % 6;
  return <Color>[
    _overviewRed,
    _overviewGreen,
    _overviewBlue,
    const Color(0xFFF59E0B),
    const Color(0xFFA78BFA),
    const Color(0xFF22D3EE),
  ][index];
}
