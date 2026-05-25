import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/empty_state.dart';
import '../widgets/transaction_item.dart';
import 'add_edit_transaction_screen.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionProvider>(
      builder: (BuildContext context, TransactionProvider provider, Widget? child) {
        final List<TransactionModel> items = provider.filteredTransactions;

        return Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
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
                            onSelected: (_) => provider.setFilter(filter),
                          );
                        }).toList(),
                  ),
                  const SizedBox(height: 10),
                  FilterChip(
                    label: const Text('Chỉ xem tháng hiện tại'),
                    selected: provider.showCurrentMonthOnly,
                    onSelected: provider.toggleCurrentMonthOnly,
                  ),
                ],
              ),
            ),
            Expanded(
              child: provider.isLoading && provider.transactions.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : items.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      children: const <Widget>[
                        EmptyState(
                          icon: Icons.filter_alt_off_rounded,
                          title: 'Không có giao dịch phù hợp',
                          message:
                              'Hãy đổi bộ lọc hoặc thêm giao dịch mới để xem dữ liệu tại đây.',
                        ),
                      ],
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: items.length,
                      itemBuilder: (BuildContext context, int index) {
                        final TransactionModel transaction = items[index];
                        return TransactionItem(
                          transaction: transaction,
                          onEdit: () =>
                              _openEditTransaction(context, transaction),
                          onDelete: () =>
                              _deleteTransaction(context, transaction),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
