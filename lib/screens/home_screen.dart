import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/overview_sections.dart';
import 'monthly_report_detail_screen.dart';
import 'spending_detail_screen.dart';
import 'transaction_search_screen.dart';
import 'wallet_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onOpenLedger});

  final VoidCallback onOpenLedger;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _balanceVisible = true;

  Future<void> _openScreen(Widget screen) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => screen));
  }

  void _showBudgetNotification({
    required double monthExpense,
    required double budgetAmount,
  }) {
    final bool hasBudget = budgetAmount > 0;
    final bool isOverBudget = hasBudget && monthExpense > budgetAmount;
    final String message = !hasBudget
        ? 'Bạn chưa đặt ngân sách tháng này.'
        : isOverBudget
        ? 'Bạn đã vượt ngân sách tháng này.'
        : 'Bạn vẫn đang trong giới hạn ngân sách.';

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Thông báo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  style: const TextStyle(
                    color: Color(0xFFA1A1AA),
                    fontSize: 15,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionProvider, BudgetProvider>(
      builder:
          (
            BuildContext context,
            TransactionProvider transactionProvider,
            BudgetProvider budgetProvider,
            Widget? child,
          ) {
            return OverviewDarkScaffold(
              child: SafeArea(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 120),
                  children: <Widget>[
                    OverviewHeader(
                      balance: transactionProvider.balance,
                      balanceVisible: _balanceVisible,
                      onSearchPressed: () {
                        _openScreen(
                          TransactionSearchScreen(
                            transactions: transactionProvider.transactions,
                          ),
                        );
                      },
                      onNotificationPressed: () {
                        _showBudgetNotification(
                          monthExpense:
                              transactionProvider.selectedMonthExpense,
                          budgetAmount:
                              budgetProvider.currentBudget?.amount ?? 0,
                        );
                      },
                      onToggleBalanceVisibility: () {
                        setState(() {
                          _balanceVisible = !_balanceVisible;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    WalletSection(
                      balance: transactionProvider.balance,
                      monthIncome: transactionProvider.selectedMonthIncome,
                      monthExpense: transactionProvider.selectedMonthExpense,
                      onViewAll: () {
                        _openScreen(
                          WalletListScreen(
                            balance: transactionProvider.balance,
                            monthIncome:
                                transactionProvider.selectedMonthIncome,
                            monthExpense:
                                transactionProvider.selectedMonthExpense,
                          ),
                        );
                      },
                    ),
                    MonthlyReportSection(
                      selectedMonth: transactionProvider.selectedMonth,
                      transactions: transactionProvider.transactions,
                      monthIncome: transactionProvider.selectedMonthIncome,
                      monthExpense: transactionProvider.selectedMonthExpense,
                      onViewReport: () {
                        _openScreen(
                          MonthlyReportDetailScreen(
                            selectedMonth: transactionProvider.selectedMonth,
                            transactions: transactionProvider.transactions,
                            balance: transactionProvider.balance,
                            monthIncome:
                                transactionProvider.selectedMonthIncome,
                            monthExpense:
                                transactionProvider.selectedMonthExpense,
                          ),
                        );
                      },
                    ),
                    TopSpendingSection(
                      selectedMonth: transactionProvider.selectedMonth,
                      transactions: transactionProvider.transactions,
                      onViewDetail: () {
                        _openScreen(
                          SpendingDetailScreen(
                            selectedMonth: transactionProvider.selectedMonth,
                            transactions: transactionProvider.transactions,
                          ),
                        );
                      },
                    ),
                    RecentTransactionsSection(
                      transactions: transactionProvider.recentTransactions,
                      onViewAll: widget.onOpenLedger,
                    ),
                  ],
                ),
              ),
            );
          },
    );
  }
}
