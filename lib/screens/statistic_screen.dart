import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../widgets/expense_pie_chart.dart';
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
                      subtitle: 'Tháng hiện tại',
                      value: CurrencyFormatter.format(
                        provider.currentMonthIncome,
                      ),
                      icon: Icons.south_west_rounded,
                      color: AppColors.success,
                    ),
                    SummaryCard(
                      title: 'Tổng chi',
                      subtitle: 'Tháng hiện tại',
                      value: CurrencyFormatter.format(
                        provider.currentMonthExpense,
                      ),
                      icon: Icons.north_east_rounded,
                      color: AppColors.danger,
                    ),
                    SummaryCard(
                      title: 'Số dư',
                      subtitle: 'Tháng hiện tại',
                      value: CurrencyFormatter.format(
                        provider.currentMonthBalance,
                      ),
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.secondary,
                    ),
                    SummaryCard(
                      title: 'Số giao dịch',
                      subtitle: 'Tháng hiện tại',
                      value: provider.currentMonthTransactionCount.toString(),
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
                ExpensePieChart(data: provider.expenseByCategoryThisMonth),
                const SizedBox(height: 18),
                MonthlyBarChart(points: provider.lastSixMonthsExpense),
              ],
            );
          },
    );
  }
}
