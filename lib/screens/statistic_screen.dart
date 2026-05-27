import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/month_selector.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/summary_card.dart';

class StatisticScreen extends StatelessWidget {
  const StatisticScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder:
          (BuildContext context, TransactionProvider provider, Widget? child) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
              children: <Widget>[
                MonthSelector(
                  selectedMonth: provider.selectedMonth,
                  onPrevious: provider.goToPreviousMonth,
                  onNext: provider.goToNextMonth,
                  onCurrentMonth: provider.resetToCurrentMonth,
                  canGoNext: !provider.isViewingCurrentMonth,
                ),
                const SizedBox(height: 18),
                GridView(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 1,
                    mainAxisExtent: 172,
                    mainAxisSpacing: 12,
                  ),
                  children: <Widget>[
                    SummaryCard(
                      title: 'Tổng thu',
                      subtitle: 'Tháng đang xem',
                      value: CurrencyFormatter.format(
                        provider.selectedMonthIncome,
                      ),
                      icon: Icons.south_west_rounded,
                      color: AppColors.success,
                    ),
                    SummaryCard(
                      title: 'Tổng chi',
                      subtitle: 'Tháng đang xem',
                      value: CurrencyFormatter.format(
                        provider.selectedMonthExpense,
                      ),
                      icon: Icons.north_east_rounded,
                      color: AppColors.danger,
                    ),
                    SummaryCard(
                      title: 'Số dư',
                      subtitle: 'Tháng đang xem',
                      value: CurrencyFormatter.format(
                        provider.selectedMonthBalance,
                      ),
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.secondary,
                    ),
                    SummaryCard(
                      title: 'Số giao dịch',
                      subtitle: 'Tháng đang xem',
                      value: provider.selectedMonthTransactionCount.toString(),
                      icon: Icons.format_list_bulleted_rounded,
                      color: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.insights_rounded,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          provider.statisticInsight,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ExpensePieChart(data: provider.expenseByCategorySelectedMonth),
                const SizedBox(height: 18),
                MonthlyBarChart(points: provider.lastSixMonthsExpense),
              ],
            );
          },
    );
  }
}
