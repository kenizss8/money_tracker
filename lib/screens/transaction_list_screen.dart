import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_constants.dart';
import 'add_edit_transaction_screen.dart';
import 'monthly_report_detail_screen.dart';
import 'transaction_search_screen.dart';
import 'wallet_list_screen.dart';

const Color _ledgerBackground = Color(0xFF000000);
const Color _ledgerCard = Color(0xFF1C1C1E);
const Color _ledgerCardSoft = Color(0xFF2C2C2E);
const Color _ledgerText = Color(0xFFFFFFFF);
const Color _ledgerTextMuted = Color(0xFFA1A1AA);
const Color _ledgerDivider = Color(0xFF34343A);
const Color _ledgerGreen = Color(0xFF34D399);
const Color _ledgerBlue = Color(0xFF60A5FA);
const Color _ledgerRed = Color(0xFFFB7185);

final NumberFormat _ledgerMoneyFormat = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: 'đ',
  decimalDigits: 2,
);

class TransactionLedgerScreen extends StatelessWidget {
  const TransactionLedgerScreen({super.key});

  Future<void> _openSearch(
    BuildContext context,
    List<TransactionModel> transactions,
  ) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransactionSearchScreen(transactions: transactions),
      ),
    );
  }

  Future<void> _openWalletList(
    BuildContext context, {
    required double balance,
    required double monthIncome,
    required double monthExpense,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => WalletListScreen(
          balance: balance,
          monthIncome: monthIncome,
          monthExpense: monthExpense,
        ),
      ),
    );
  }

  Future<void> _openPeriodReport(
    BuildContext context, {
    required DateTime selectedMonth,
    required List<TransactionModel> transactions,
    required double balance,
    required double monthIncome,
    required double monthExpense,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MonthlyReportDetailScreen(
          selectedMonth: selectedMonth,
          transactions: transactions,
          balance: balance,
          monthIncome: monthIncome,
          monthExpense: monthExpense,
        ),
      ),
    );
  }

  void _showLedgerHelp(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Sổ giao dịch'),
          content: const Text(
            'Mỗi giao dịch được nhóm theo ngày. Chạm vào giao dịch để sửa, nhấn giữ để xóa.',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đã hiểu'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openEditTransaction(
    BuildContext context,
    LedgerTransaction transaction,
  ) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) =>
            AddEditTransactionScreen(transaction: transaction.source),
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
    LedgerTransaction transaction,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ledgerBackground,
      body: SafeArea(
        child: Consumer<TransactionProvider>(
          builder:
              (
                BuildContext context,
                TransactionProvider provider,
                Widget? child,
              ) {
                final DateTime selectedMonth = _monthStart(
                  provider.selectedMonth,
                );
                final List<TransactionModel> allTransactions =
                    provider.transactions;
                final List<TransactionModel> periodTransactions =
                    _transactionsForMonth(allTransactions, selectedMonth);
                final List<LedgerDayGroup> dayGroups = _buildDayGroups(
                  periodTransactions,
                );
                final _LedgerPeriodSummary periodSummary = _buildPeriodSummary(
                  allTransactions,
                  selectedMonth,
                );
                final double monthIncome = _sumByType(
                  periodTransactions,
                  AppConstants.incomeType,
                );
                final double monthExpense = _sumByType(
                  periodTransactions,
                  AppConstants.expenseType,
                );
                final List<LedgerPeriodTabData> tabs = _buildPeriodTabs(
                  allTransactions,
                  selectedMonth,
                );

                return CustomScrollView(
                  slivers: <Widget>[
                    SliverToBoxAdapter(
                      child: LedgerTopBar(
                        onHelpPressed: () => _showLedgerHelp(context),
                        onAccountPressed: () => _openWalletList(
                          context,
                          balance: periodSummary.endingBalance,
                          monthIncome: monthIncome,
                          monthExpense: monthExpense,
                        ),
                        onSearchPressed: () =>
                            _openSearch(context, allTransactions),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: LedgerBalanceSummary(
                        balance: periodSummary.endingBalance,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: LedgerTimeTabs(
                        tabs: tabs,
                        selectedMonth: selectedMonth,
                        onMonthSelected: provider.setSelectedMonth,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: LedgerPeriodSummaryCard(
                        startingBalance: periodSummary.startingBalance,
                        endingBalance: periodSummary.endingBalance,
                        periodTotal: periodSummary.periodTotal,
                        onViewReport: () => _openPeriodReport(
                          context,
                          selectedMonth: selectedMonth,
                          transactions: allTransactions,
                          balance: periodSummary.endingBalance,
                          monthIncome: monthIncome,
                          monthExpense: monthExpense,
                        ),
                      ),
                    ),
                    if (provider.isLoading && allTransactions.isEmpty)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 48),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: _ledgerGreen,
                            ),
                          ),
                        ),
                      )
                    else
                      LedgerTransactionList(
                        groups: dayGroups,
                        selectedMonth: selectedMonth,
                        onTransactionTap: (LedgerTransaction transaction) {
                          _openEditTransaction(context, transaction);
                        },
                        onTransactionLongPress:
                            (LedgerTransaction transaction) {
                              _deleteTransaction(context, transaction);
                            },
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 156)),
                  ],
                );
              },
        ),
      ),
    );
  }
}

class LedgerTopBar extends StatelessWidget {
  const LedgerTopBar({
    super.key,
    required this.onHelpPressed,
    required this.onAccountPressed,
    required this.onSearchPressed,
  });

  final VoidCallback onHelpPressed;
  final VoidCallback onAccountPressed;
  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 18),
      child: Row(
        children: <Widget>[
          _LedgerIconButton(
            icon: Icons.question_mark_rounded,
            onPressed: onHelpPressed,
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 180),
                child: AccountSelectorPill(onTap: onAccountPressed),
              ),
            ),
          ),
          _LedgerSearchMenuPill(onSearchPressed: onSearchPressed),
        ],
      ),
    );
  }
}

class AccountSelectorPill extends StatelessWidget {
  const AccountSelectorPill({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ledgerCard,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.public_rounded, color: _ledgerText, size: 19),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'Tổng cộng',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: _ledgerText,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              SizedBox(width: 6),
              Icon(
                Icons.unfold_more_rounded,
                color: _ledgerTextMuted,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LedgerBalanceSummary extends StatelessWidget {
  const LedgerBalanceSummary({super.key, required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
      child: Column(
        children: <Widget>[
          const Text(
            'Số dư',
            style: TextStyle(
              color: _ledgerTextMuted,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _formatLedgerMoney(balance),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _ledgerText,
                fontSize: 34,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LedgerTimeTabs extends StatelessWidget {
  const LedgerTimeTabs({
    super.key,
    required this.tabs,
    required this.selectedMonth,
    required this.onMonthSelected,
  });

  final List<LedgerPeriodTabData> tabs;
  final DateTime selectedMonth;
  final ValueChanged<DateTime> onMonthSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: tabs.map((LedgerPeriodTabData tab) {
          final bool selected =
              tab.month != null && _isSameMonth(tab.month!, selectedMonth);
          final bool enabled = tab.enabled && tab.month != null;

          return Padding(
            padding: const EdgeInsets.only(right: 24),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? () => onMonthSelected(tab.month!) : null,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    tab.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? _ledgerText
                          : enabled
                          ? _ledgerTextMuted
                          : _ledgerTextMuted.withValues(alpha: 0.42),
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.w900 : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 9),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: selected ? 34 : 0,
                    height: 2,
                    decoration: BoxDecoration(
                      color: _ledgerText,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LedgerPeriodSummaryCard extends StatelessWidget {
  const LedgerPeriodSummaryCard({
    super.key,
    required this.startingBalance,
    required this.endingBalance,
    required this.periodTotal,
    required this.onViewReport,
  });

  final double startingBalance;
  final double endingBalance;
  final double periodTotal;
  final VoidCallback onViewReport;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: _ledgerCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _LedgerSummaryRow(
            label: 'Số dư đầu',
            value: _formatLedgerMoney(startingBalance, signed: true),
          ),
          const SizedBox(height: 14),
          _LedgerSummaryRow(
            label: 'Số dư cuối',
            value: _formatLedgerMoney(endingBalance, signed: true),
          ),
          const SizedBox(height: 10),
          const Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 132,
              child: Divider(color: _ledgerDivider, height: 24),
            ),
          ),
          Row(
            children: <Widget>[
              const Spacer(),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatLedgerMoney(periodTotal, signed: true),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _ledgerText,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Center(
            child: TextButton(
              onPressed: onViewReport,
              child: const Text(
                'Xem báo cáo cho giai đoạn này',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _ledgerGreen,
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

class LedgerTransactionList extends StatelessWidget {
  const LedgerTransactionList({
    super.key,
    required this.groups,
    required this.selectedMonth,
    this.onTransactionTap,
    this.onTransactionLongPress,
  });

  final List<LedgerDayGroup> groups;
  final DateTime selectedMonth;
  final ValueChanged<LedgerTransaction>? onTransactionTap;
  final ValueChanged<LedgerTransaction>? onTransactionLongPress;

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
      return SliverToBoxAdapter(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: _ledgerCard,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: <Widget>[
              CircleAvatar(
                radius: 28,
                backgroundColor: _ledgerCardSoft,
                child: Icon(
                  Icons.receipt_long_rounded,
                  color: _ledgerTextMuted.withValues(alpha: 0.88),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Chưa có giao dịch trong ${_periodEmptyLabel(selectedMonth)}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: _ledgerText,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Các giao dịch mới sẽ xuất hiện tại đây theo từng ngày.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _ledgerTextMuted, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return DailyTransactionCard(
          group: groups[index],
          onTransactionTap: onTransactionTap,
          onTransactionLongPress: onTransactionLongPress,
        );
      }, childCount: groups.length),
    );
  }
}

class DailyTransactionCard extends StatelessWidget {
  const DailyTransactionCard({
    super.key,
    required this.group,
    this.onTransactionTap,
    this.onTransactionLongPress,
  });

  final LedgerDayGroup group;
  final ValueChanged<LedgerTransaction>? onTransactionTap;
  final ValueChanged<LedgerTransaction>? onTransactionLongPress;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _ledgerCard,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              SizedBox(
                width: 64,
                child: Text(
                  group.date.day.toString().padLeft(2, '0'),
                  style: const TextStyle(
                    color: _ledgerText,
                    fontSize: 46,
                    height: 1,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        _formatWeekday(group.date),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ledgerTextMuted,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'tháng ${group.date.month} ${group.date.year}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: _ledgerTextMuted,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: Text(
                    _formatLedgerMoney(group.total, signed: true),
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: _ledgerText,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          for (int index = 0; index < group.transactions.length; index++)
            Padding(
              padding: EdgeInsets.only(
                bottom: index == group.transactions.length - 1 ? 0 : 24,
              ),
              child: LedgerTransactionItem(
                transaction: group.transactions[index],
                onTap: onTransactionTap == null
                    ? null
                    : () => onTransactionTap!(group.transactions[index]),
                onLongPress: onTransactionLongPress == null
                    ? null
                    : () => onTransactionLongPress!(group.transactions[index]),
              ),
            ),
        ],
      ),
    );
  }
}

class LedgerTransactionItem extends StatelessWidget {
  const LedgerTransactionItem({
    super.key,
    required this.transaction,
    this.onTap,
    this.onLongPress,
  });

  final LedgerTransaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  @override
  Widget build(BuildContext context) {
    final Color amountColor = transaction.isIncome ? _ledgerBlue : _ledgerRed;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(18),
        child: Row(
          children: <Widget>[
            TransactionCategoryIcon(transaction: transaction),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    transaction.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ledgerText,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    transaction.note.isEmpty
                        ? 'Không có ghi chú'
                        : transaction.note,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: _ledgerTextMuted,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 128),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _formatLedgerMoney(transaction.signedAmount, signed: true),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    color: amountColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionCategoryIcon extends StatelessWidget {
  const TransactionCategoryIcon({super.key, required this.transaction});

  final LedgerTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final Color color = _categoryColor(transaction);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        CircleAvatar(
          radius: 28,
          backgroundColor: color.withValues(alpha: 0.16),
          child: Icon(_categoryIcon(transaction), color: color, size: 24),
        ),
        Positioned(
          right: -2,
          bottom: -2,
          child: Container(
            width: 21,
            height: 21,
            decoration: BoxDecoration(
              color: _ledgerGreen,
              shape: BoxShape.circle,
              border: Border.all(color: _ledgerCard, width: 3),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: _ledgerBackground,
              size: 11,
            ),
          ),
        ),
      ],
    );
  }
}

class LedgerDayGroup {
  const LedgerDayGroup({required this.date, required this.transactions});

  final DateTime date;
  final List<LedgerTransaction> transactions;

  double get total => transactions.fold<double>(
    0,
    (double sum, LedgerTransaction transaction) =>
        sum + transaction.signedAmount,
  );
}

class LedgerTransaction {
  const LedgerTransaction({
    required this.id,
    required this.title,
    required this.note,
    required this.amount,
    required this.type,
    required this.date,
    required this.source,
  });

  final String id;
  final String title;
  final String note;
  final double amount;
  final String type;
  final DateTime date;
  final TransactionModel source;

  bool get isIncome => type == AppConstants.incomeType;
  double get signedAmount => isIncome ? amount : -amount;
}

class _LedgerIconButton extends StatelessWidget {
  const _LedgerIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ledgerCard,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: _ledgerText, size: 22),
        ),
      ),
    );
  }
}

class _LedgerSearchMenuPill extends StatelessWidget {
  const _LedgerSearchMenuPill({required this.onSearchPressed});

  final VoidCallback onSearchPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _ledgerCard,
      borderRadius: BorderRadius.circular(999),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _LedgerPillIcon(
            icon: Icons.search_rounded,
            onPressed: onSearchPressed,
          ),
        ],
      ),
    );
  }
}

class _LedgerPillIcon extends StatelessWidget {
  const _LedgerPillIcon({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        width: 42,
        height: 48,
        child: Icon(icon, color: _ledgerText, size: 22),
      ),
    );
  }
}

class _LedgerSummaryRow extends StatelessWidget {
  const _LedgerSummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: _ledgerTextMuted,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: _ledgerText,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class LedgerPeriodTabData {
  const LedgerPeriodTabData({
    required this.label,
    this.month,
    this.enabled = true,
  });

  final String label;
  final DateTime? month;
  final bool enabled;
}

class _LedgerPeriodSummary {
  const _LedgerPeriodSummary({
    required this.startingBalance,
    required this.endingBalance,
    required this.periodTotal,
  });

  final double startingBalance;
  final double endingBalance;
  final double periodTotal;
}

List<TransactionModel> _transactionsForMonth(
  List<TransactionModel> transactions,
  DateTime month,
) {
  return transactions.where((TransactionModel transaction) {
    return _isSameMonth(transaction.date, month);
  }).toList()..sort(
    (TransactionModel a, TransactionModel b) => b.date.compareTo(a.date),
  );
}

List<LedgerDayGroup> _buildDayGroups(List<TransactionModel> transactions) {
  final Map<DateTime, List<LedgerTransaction>> grouped =
      <DateTime, List<LedgerTransaction>>{};

  for (final TransactionModel transaction in transactions) {
    final DateTime day = _dayStart(transaction.date);
    grouped
        .putIfAbsent(day, () => <LedgerTransaction>[])
        .add(
          LedgerTransaction(
            id: transaction.id,
            title: transaction.category,
            note: transaction.note,
            amount: transaction.amount,
            type: transaction.type,
            date: transaction.date,
            source: transaction,
          ),
        );
  }

  final List<DateTime> sortedDays = grouped.keys.toList()
    ..sort((DateTime a, DateTime b) => b.compareTo(a));

  return sortedDays.map((DateTime day) {
    final List<LedgerTransaction> dayTransactions = grouped[day]!
      ..sort(
        (LedgerTransaction a, LedgerTransaction b) => b.date.compareTo(a.date),
      );
    return LedgerDayGroup(date: day, transactions: dayTransactions);
  }).toList();
}

_LedgerPeriodSummary _buildPeriodSummary(
  List<TransactionModel> transactions,
  DateTime selectedMonth,
) {
  final DateTime start = _monthStart(selectedMonth);
  final DateTime end = DateTime(start.year, start.month + 1);
  double startingBalance = 0;
  double periodTotal = 0;

  for (final TransactionModel transaction in transactions) {
    final double signedAmount = transaction.type == AppConstants.incomeType
        ? transaction.amount
        : -transaction.amount;

    if (transaction.date.isBefore(start)) {
      startingBalance += signedAmount;
      continue;
    }

    if (transaction.date.isBefore(end)) {
      periodTotal += signedAmount;
    }
  }

  return _LedgerPeriodSummary(
    startingBalance: startingBalance,
    endingBalance: startingBalance + periodTotal,
    periodTotal: periodTotal,
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

List<LedgerPeriodTabData> _buildPeriodTabs(
  List<TransactionModel> transactions,
  DateTime selectedMonth,
) {
  final DateTime now = DateTime.now();
  final DateTime currentMonth = _monthStart(now);
  final DateTime previousMonth = DateTime(now.year, now.month - 1);
  final Set<DateTime> olderMonths = <DateTime>{};

  for (final TransactionModel transaction in transactions) {
    final DateTime month = _monthStart(transaction.date);
    if (month.isBefore(previousMonth)) {
      olderMonths.add(month);
    }
  }

  if (selectedMonth.isBefore(previousMonth)) {
    olderMonths.add(selectedMonth);
  }

  final List<DateTime> sortedOlderMonths = olderMonths.toList()
    ..sort((DateTime a, DateTime b) => b.compareTo(a));

  return <LedgerPeriodTabData>[
    LedgerPeriodTabData(label: '${currentMonth.year}', enabled: false),
    LedgerPeriodTabData(label: 'THÁNG TRƯỚC', month: previousMonth),
    LedgerPeriodTabData(label: 'THÁNG NÀY', month: currentMonth),
    const LedgerPeriodTabData(label: 'TƯƠNG LAI', enabled: false),
    ...sortedOlderMonths.map(
      (DateTime month) => LedgerPeriodTabData(
        label: 'THÁNG ${month.month} ${month.year}',
        month: month,
      ),
    ),
  ];
}

String _formatLedgerMoney(num amount, {bool signed = false}) {
  final String formatted = _ledgerMoneyFormat.format(amount.abs());
  if (!signed || amount == 0) {
    return formatted;
  }
  return amount > 0 ? '+$formatted' : '-$formatted';
}

String _formatWeekday(DateTime date) {
  final String weekday = DateFormat('EEEE', 'vi_VN').format(date);
  if (weekday.isEmpty) {
    return weekday;
  }
  return weekday[0].toUpperCase() + weekday.substring(1);
}

String _periodEmptyLabel(DateTime month) {
  final DateTime now = DateTime.now();
  final DateTime currentMonth = _monthStart(now);
  final DateTime previousMonth = DateTime(now.year, now.month - 1);

  if (_isSameMonth(month, currentMonth)) {
    return 'tháng này';
  }
  if (_isSameMonth(month, previousMonth)) {
    return 'tháng trước';
  }
  return 'tháng ${month.month} ${month.year}';
}

IconData _categoryIcon(LedgerTransaction transaction) {
  if (transaction.isIncome) {
    switch (transaction.title) {
      case 'Lương':
        return Icons.payments_rounded;
      case 'Làm thêm':
        return Icons.work_history_rounded;
      case 'Học bổng':
        return Icons.school_rounded;
      case 'Tiền được cho':
      case 'Tiền chuyển đến':
        return Icons.call_received_rounded;
      default:
        return Icons.savings_rounded;
    }
  }

  switch (transaction.title) {
    case 'Ăn uống':
      return Icons.restaurant_rounded;
    case 'Đi lại':
    case 'Di chuyển':
      return Icons.directions_car_rounded;
    case 'Mua sắm':
      return Icons.shopping_bag_rounded;
    case 'Học tập':
      return Icons.menu_book_rounded;
    case 'Giải trí':
      return Icons.movie_creation_outlined;
    case 'Hóa đơn':
    case 'Hoá đơn tiện ích':
      return Icons.receipt_long_rounded;
    case 'Sức khỏe':
    case 'Khám sức khoẻ':
      return Icons.health_and_safety_rounded;
    case 'Gia đình':
      return Icons.family_restroom_rounded;
    case 'Làm đẹp':
      return Icons.spa_rounded;
    default:
      return Icons.category_rounded;
  }
}

Color _categoryColor(LedgerTransaction transaction) {
  if (transaction.isIncome) {
    return _ledgerBlue;
  }

  switch (transaction.title) {
    case 'Ăn uống':
      return const Color(0xFFF59E0B);
    case 'Đi lại':
    case 'Di chuyển':
      return const Color(0xFF22D3EE);
    case 'Mua sắm':
      return const Color(0xFFA78BFA);
    case 'Học tập':
      return const Color(0xFF38BDF8);
    case 'Giải trí':
      return const Color(0xFFF472B6);
    case 'Hóa đơn':
    case 'Hoá đơn tiện ích':
      return const Color(0xFFCBD5E1);
    case 'Sức khỏe':
    case 'Khám sức khoẻ':
      return const Color(0xFFFB7185);
    default:
      return _ledgerRed;
  }
}

bool _isSameMonth(DateTime left, DateTime right) {
  return left.year == right.year && left.month == right.month;
}

DateTime _monthStart(DateTime date) {
  return DateTime(date.year, date.month);
}

DateTime _dayStart(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
