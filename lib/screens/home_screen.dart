import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder:
          (
            BuildContext context,
            TransactionProvider transactionProvider,
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
