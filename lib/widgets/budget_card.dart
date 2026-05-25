import 'package:flutter/material.dart';

import '../models/budget_model.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';

class BudgetCard extends StatelessWidget {
  const BudgetCard({
    super.key,
    required this.budget,
    required this.currentExpense,
    this.onTap,
  });

  final BudgetModel? budget;
  final double currentExpense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasBudget = budget != null;
    final double remaining = (budget?.amount ?? 0) - currentExpense;
    final bool isOverBudget = hasBudget && currentExpense > budget!.amount;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
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
                      color: AppColors.warning.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Ngân sách tháng này',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded),
                ],
              ),
              const SizedBox(height: 16),
              if (!hasBudget) ...<Widget>[
                const Text(
                  'Bạn chưa đặt ngân sách cho tháng hiện tại.',
                  style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Nhấn vào đây để thêm ngân sách và theo dõi mức chi.',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ] else ...<Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _BudgetInfo(
                        title: 'Ngân sách',
                        value: CurrencyFormatter.format(budget!.amount),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _BudgetInfo(
                        title: 'Đã chi',
                        value: CurrencyFormatter.format(currentExpense),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isOverBudget
                        ? AppColors.danger.withValues(alpha: 0.08)
                        : AppColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    isOverBudget
                        ? 'Bạn đã vượt ngân sách tháng này'
                        : 'Bạn vẫn còn ${CurrencyFormatter.format(remaining)} để chi trong tháng này',
                    style: TextStyle(
                      color: isOverBudget
                          ? AppColors.danger
                          : AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
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

class _BudgetInfo extends StatelessWidget {
  const _BudgetInfo({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(title, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
