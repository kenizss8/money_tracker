import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/auth_provider.dart';
import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/budget_card.dart';
import '../widgets/custom_button.dart';
import '../widgets/empty_state.dart';
import '../widgets/summary_card.dart';
import '../widgets/transaction_item.dart';
import 'add_edit_transaction_screen.dart';
import 'budget_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openBudget(BuildContext context) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const BudgetScreen()),
    );

    if (!context.mounted || message == null) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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

  Future<void> _openAddTransaction(BuildContext context) async {
    final String? message = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => const AddEditTransactionScreen(),
      ),
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
    return Consumer3<AuthProvider, TransactionProvider, BudgetProvider>(
      builder:
          (
            BuildContext context,
            AuthProvider authProvider,
            TransactionProvider transactionProvider,
            BudgetProvider budgetProvider,
            Widget? child,
          ) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 112),
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[AppColors.primary, AppColors.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Xin chào, ${authProvider.displayName}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tổng quan thu chi tháng ${DateFormatter.formatMonthYear(DateTime.now())}',
                        style: const TextStyle(
                          color: Colors.white70,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 18),
                      CustomButton(
                        label: 'Thêm giao dịch mới',
                        icon: Icons.add_circle_outline_rounded,
                        isOutlined: true,
                        onPressed: () => _openAddTransaction(context),
                      ),
                    ],
                  ),
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
                      subtitle: 'Tháng hiện tại',
                      value: CurrencyFormatter.format(
                        transactionProvider.currentMonthIncome,
                      ),
                      icon: Icons.arrow_downward_rounded,
                      color: AppColors.success,
                    ),
                    SummaryCard(
                      title: 'Tổng chi',
                      subtitle: 'Tháng hiện tại',
                      value: CurrencyFormatter.format(
                        transactionProvider.currentMonthExpense,
                      ),
                      icon: Icons.arrow_upward_rounded,
                      color: AppColors.danger,
                    ),
                    SummaryCard(
                      title: 'Số dư',
                      subtitle: 'Tháng hiện tại',
                      value: CurrencyFormatter.format(
                        transactionProvider.currentMonthBalance,
                      ),
                      icon: Icons.account_balance_wallet_rounded,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                BudgetCard(
                  budget: budgetProvider.currentBudget,
                  currentExpense: transactionProvider.currentMonthExpense,
                  onTap: () => _openBudget(context),
                ),
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    const Expanded(
                      child: Text(
                        'Giao dịch gần đây',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    Text(
                      '${transactionProvider.recentTransactions.length} mục',
                      style: const TextStyle(color: AppColors.textSecondary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (transactionProvider.isLoading &&
                    transactionProvider.transactions.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (transactionProvider.recentTransactions.isEmpty)
                  const EmptyState(
                    icon: Icons.receipt_long_rounded,
                    title: 'Chưa có giao dịch nào',
                    message:
                        'Hãy thêm giao dịch đầu tiên để bắt đầu theo dõi thu chi của bạn.',
                  )
                else
                  ...transactionProvider.recentTransactions.map(
                    (TransactionModel transaction) => TransactionItem(
                      transaction: transaction,
                      onEdit: () => _openEditTransaction(context, transaction),
                      onDelete: () => _deleteTransaction(context, transaction),
                    ),
                  ),
              ],
            );
          },
    );
  }
}
