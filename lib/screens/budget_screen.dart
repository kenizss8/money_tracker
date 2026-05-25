import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/budget_provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_colors.dart';
import '../utils/currency_formatter.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  bool _didPrefill = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final bool success = await context
        .read<BudgetProvider>()
        .saveCurrentMonthBudget(amount);

    if (!mounted) {
      return;
    }

    if (success) {
      Navigator.of(context).pop<String>('Lưu ngân sách thành công');
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Không thể lưu ngân sách')));
  }

  @override
  Widget build(BuildContext context) {
    final BudgetProvider budgetProvider = context.watch<BudgetProvider>();
    final TransactionProvider transactionProvider = context
        .watch<TransactionProvider>();

    if (!_didPrefill && budgetProvider.currentBudget != null) {
      _amountController.text = budgetProvider.currentBudget!.amount
          .toStringAsFixed(0);
      _didPrefill = true;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Ngân sách tháng')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Tháng ${DateFormatter.formatMonthYear(DateTime.now())}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'Đã chi: ${CurrencyFormatter.format(transactionProvider.currentMonthExpense)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      budgetProvider.budgetStatusMessage(
                        transactionProvider.currentMonthExpense,
                      ),
                      style: TextStyle(
                        color:
                            budgetProvider.isOverBudget(
                              transactionProvider.currentMonthExpense,
                            )
                            ? AppColors.danger
                            : AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              CustomTextField(
                controller: _amountController,
                label: 'Ngân sách tháng',
                hintText: 'Ví dụ: 3000000',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                prefixIcon: Icons.savings_outlined,
                validator: (String? value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ngân sách không được bỏ trống';
                  }
                  final double? amount = double.tryParse(value.trim());
                  if (amount == null || amount <= 0) {
                    return 'Ngân sách phải lớn hơn 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              CustomButton(
                label: 'Lưu ngân sách',
                icon: Icons.check_circle_outline_rounded,
                isLoading: budgetProvider.isSaving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
