import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/empty_state.dart';
import '../widgets/month_selector.dart';
import '../widgets/transaction_item.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() => _TransactionListScreenState();
}

class _TransactionListScreenState extends State<TransactionListScreen> {
  DateTime? _selectedDay;

  Future<void> _openEditTransaction(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => AddEditTransactionScreen(transaction: transaction),
      ),
    );

    if (!context.mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _deleteTransaction(
    BuildContext context,
    TransactionModel transaction,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa giao dịch'),
          content: const Text('Bạn có chắc chắn muốn xóa giao dịch này không?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final bool success = await context
        .read<TransactionProvider>()
        .deleteTransaction(transaction.id);

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success ? 'Xóa giao dịch thành công' : 'Không thể xóa giao dịch',
        ),
      ),
    );
  }

  void _runWithDayReset(VoidCallback action) {
    setState(() {
      _selectedDay = null;
    });
    action();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (BuildContext context, TransactionProvider provider, Widget? child) {
        final List<TransactionModel> monthTransactions = _filterByType(
          provider.selectedMonthTransactions,
          provider,
        );
        final List<DateTime> days = _daysInMonth(provider.selectedMonth);
        final DateTime selectedDay = _resolveSelectedDay(
          provider.selectedMonth,
          monthTransactions,
        );
        final List<TransactionModel> dayTransactions = _transactionsForDay(
          monthTransactions,
          selectedDay,
        );
        final double dayIncome = _sumByType(
          dayTransactions,
          AppConstants.incomeType,
        );
        final double dayExpense = _sumByType(
          dayTransactions,
          AppConstants.expenseType,
        );

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  MonthSelector(
                    selectedMonth: provider.selectedMonth,
                    onPrevious: () =>
                        _runWithDayReset(provider.goToPreviousMonth),
                    onNext: () => _runWithDayReset(provider.goToNextMonth),
                    onCurrentMonth: () =>
                        _runWithDayReset(provider.resetToCurrentMonth),
                    canGoNext: !provider.isViewingCurrentMonth,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        <String>[
                          AppConstants.filterAll,
                          AppConstants.filterIncome,
                          AppConstants.filterExpense,
                        ].map((String filter) {
                          return ChoiceChip(
                            label: Text(AppConstants.filterLabel(filter)),
                            selected: provider.selectedFilter == filter,
                            onSelected: (_) => _runWithDayReset(
                              () => provider.setFilter(filter),
                            ),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 12),
                  _DayStripSelector(
                    days: days,
                    selectedDay: selectedDay,
                    transactions: monthTransactions,
                    onSelected: (DateTime day) {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading && provider.transactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : dayTransactions.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      children: <Widget>[
                        _SelectedDaySummary(
                          date: selectedDay,
                          income: dayIncome,
                          expense: dayExpense,
                        ),
                        const SizedBox(height: 12),
                        const EmptyState(
                          icon: Icons.event_busy_rounded,
                          title: 'Ngày này chưa có giao dịch',
                          message:
                              'Hãy chọn ngày khác hoặc thêm giao dịch mới cho ngày đang chọn.',
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      children: <Widget>[
                        _SelectedDaySummary(
                          date: selectedDay,
                          income: dayIncome,
                          expense: dayExpense,
                        ),
                        const SizedBox(height: 12),
                        ...dayTransactions.map(
                          (TransactionModel transaction) => TransactionItem(
                            transaction: transaction,
                            showDate: false,
                            onEdit: () =>
                                _openEditTransaction(context, transaction),
                            onDelete: () =>
                                _deleteTransaction(context, transaction),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  DateTime _resolveSelectedDay(
    DateTime selectedMonth,
    List<TransactionModel> transactions,
  ) {
    final DateTime? selectedDay = _selectedDay;
    if (selectedDay != null &&
        selectedDay.year == selectedMonth.year &&
        selectedDay.month == selectedMonth.month) {
      return _dayStart(selectedDay);
    }

    if (transactions.isNotEmpty) {
      return _dayStart(transactions.first.date);
    }

    final DateTime now = DateTime.now();
    if (now.year == selectedMonth.year && now.month == selectedMonth.month) {
      return _dayStart(now);
    }

    return DateTime(selectedMonth.year, selectedMonth.month);
  }
}

class _DayStripSelector extends StatefulWidget {
  const _DayStripSelector({
    required this.days,
    required this.selectedDay,
    required this.transactions,
    required this.onSelected,
  });

  final List<DateTime> days;
  final DateTime selectedDay;
  final List<TransactionModel> transactions;
  final ValueChanged<DateTime> onSelected;

  @override
  State<_DayStripSelector> createState() => _DayStripSelectorState();
}

class _DayStripSelectorState extends State<_DayStripSelector> {
  static const double _pillWidth = 76;
  static const double _separatorWidth = 10;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scheduleScrollToSelected(animate: false);
  }

  @override
  void didUpdateWidget(covariant _DayStripSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool selectedDayChanged = !_isSameDay(
      oldWidget.selectedDay,
      widget.selectedDay,
    );
    final bool daysChanged =
        oldWidget.days.length != widget.days.length ||
        oldWidget.days.firstOrNull != widget.days.firstOrNull ||
        oldWidget.days.lastOrNull != widget.days.lastOrNull;

    if (selectedDayChanged || daysChanged) {
      _scheduleScrollToSelected();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scheduleScrollToSelected({bool animate = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) {
        return;
      }

      final int selectedIndex = widget.days.indexWhere(
        (DateTime day) => _isSameDay(day, widget.selectedDay),
      );
      if (selectedIndex < 0) {
        return;
      }

      final double viewportWidth = _scrollController.position.viewportDimension;
      final double rawOffset =
          selectedIndex * (_pillWidth + _separatorWidth) -
          (viewportWidth - _pillWidth) / 2;
      final double targetOffset = rawOffset.clamp(
        0,
        _scrollController.position.maxScrollExtent,
      );

      if (animate) {
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
        );
      } else {
        _scrollController.jumpTo(targetOffset);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108,
      child: ListView.separated(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        itemCount: widget.days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (BuildContext context, int index) {
          final DateTime day = widget.days[index];
          final bool selected = _isSameDay(day, widget.selectedDay);
          final List<TransactionModel> dayTransactions = _transactionsForDay(
            widget.transactions,
            day,
          );
          final bool hasTransactions = dayTransactions.isNotEmpty;
          final double expense = _sumByType(
            dayTransactions,
            AppConstants.expenseType,
          );

          return _DayPill(
            day: day,
            selected: selected,
            hasTransactions: hasTransactions,
            expense: expense,
            onTap: () => widget.onSelected(day),
          );
        },
      ),
    );
  }
}

class _DayPill extends StatelessWidget {
  const _DayPill({
    required this.day,
    required this.selected,
    required this.hasTransactions,
    required this.expense,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final bool hasTransactions;
  final double expense;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 76,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
            ),
            boxShadow: selected
                ? <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                DateFormatter.formatWeekdayShort(day),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white70 : AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                day.day.toString(),
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              if (hasTransactions)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: selected ? Colors.white : AppColors.primary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                )
              else
                const SizedBox(height: 8),
              if (expense > 0) ...<Widget>[
                const SizedBox(height: 3),
                Text(
                  '${(expense / 1000).round()}K',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: selected ? Colors.white70 : AppColors.danger,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectedDaySummary extends StatelessWidget {
  const _SelectedDaySummary({
    required this.date,
    required this.income,
    required this.expense,
  });

  final DateTime date;
  final double income;
  final double expense;

  @override
  Widget build(BuildContext context) {
    final double balance = income - expense;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      DateFormatter.formatDayHeader(date),
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.formatDate(date),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: <Widget>[
              _SummaryPill(
                label: 'Thu',
                value: '+${CurrencyFormatter.format(income)}',
                color: AppColors.success,
              ),
              _SummaryPill(
                label: 'Chi',
                value: '-${CurrencyFormatter.format(expense)}',
                color: AppColors.danger,
              ),
              _SummaryPill(
                label: 'Còn lại',
                value: CurrencyFormatter.format(balance),
                color: balance >= 0 ? AppColors.success : AppColors.danger,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

List<DateTime> _daysInMonth(DateTime month) {
  final int totalDays = DateTime(month.year, month.month + 1, 0).day;
  return List<DateTime>.generate(
    totalDays,
    (int index) => DateTime(month.year, month.month, index + 1),
  );
}

List<TransactionModel> _filterByType(
  List<TransactionModel> transactions,
  TransactionProvider provider,
) {
  if (provider.selectedFilter == AppConstants.filterAll) {
    return transactions;
  }

  return transactions
      .where(
        (TransactionModel transaction) =>
            transaction.type == provider.selectedFilter,
      )
      .toList();
}

List<TransactionModel> _transactionsForDay(
  List<TransactionModel> transactions,
  DateTime day,
) {
  return transactions
      .where(
        (TransactionModel transaction) => _isSameDay(transaction.date, day),
      )
      .toList()
    ..sort(
      (TransactionModel a, TransactionModel b) => b.date.compareTo(a.date),
    );
}

double _sumByType(List<TransactionModel> transactions, String type) {
  return transactions
      .where((TransactionModel transaction) => transaction.type == type)
      .fold<double>(
        0,
        (double sum, TransactionModel transaction) => sum + transaction.amount,
      );
}

bool _isSameDay(DateTime left, DateTime right) {
  return left.year == right.year &&
      left.month == right.month &&
      left.day == right.day;
}

DateTime _dayStart(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
