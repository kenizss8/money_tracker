import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/app_constants.dart';
import '../utils/date_formatter.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';

class AddEditTransactionScreen extends StatefulWidget {
  const AddEditTransactionScreen({super.key, this.transaction});

  final TransactionModel? transaction;

  @override
  State<AddEditTransactionScreen> createState() =>
      _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  bool get _isEditing => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    final TransactionModel? transaction = widget.transaction;
    _selectedType = transaction?.type ?? AppConstants.expenseType;
    _selectedCategory =
        transaction?.category ??
        AppConstants.categoriesFor(_selectedType).first;
    _selectedDate = transaction?.date ?? _defaultDateForSelectedMonth();
    _amountController.text = transaction == null
        ? ''
        : transaction.amount.toStringAsFixed(0);
    _noteController.text = transaction?.note ?? '';
    _dateController.text = DateFormatter.formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = _selectedDate.isAfter(now)
        ? now
        : _selectedDate;
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormatter.formatDate(_selectedDate);
      });
    }
  }

  DateTime _defaultDateForSelectedMonth() {
    final DateTime selectedMonth = context
        .read<TransactionProvider>()
        .selectedMonth;
    final DateTime now = DateTime.now();

    if (selectedMonth.year == now.year && selectedMonth.month == now.month) {
      return now;
    }

    return DateTime(selectedMonth.year, selectedMonth.month);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final double amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final DateTime now = DateTime.now();
    final TransactionModel transaction = TransactionModel(
      id: widget.transaction?.id ?? '',
      type: _selectedType,
      amount: amount,
      category: _selectedCategory,
      note: _noteController.text.trim(),
      date: _selectedDate,
      createdAt: widget.transaction?.createdAt ?? now,
      updatedAt: now,
    );

    final TransactionProvider provider = context.read<TransactionProvider>();
    final bool success = _isEditing
        ? await provider.updateTransaction(transaction)
        : await provider.addTransaction(transaction);

    if (!mounted) {
      return;
    }

    final String message = success
        ? (_isEditing
              ? 'Cập nhật giao dịch thành công'
              : 'Thêm giao dịch thành công')
        : (_isEditing
              ? 'Không thể cập nhật giao dịch'
              : 'Không thể thêm giao dịch');

    if (success) {
      Navigator.of(context).pop<String>(message);
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final TransactionProvider provider = context.watch<TransactionProvider>();
    final List<String> categories = AppConstants.categoriesFor(_selectedType);

    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Sửa giao dịch' : 'Thêm giao dịch'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Loại giao dịch',
                    prefixIcon: Icon(Icons.swap_horiz_rounded),
                  ),
                  items: const <DropdownMenuItem<String>>[
                    DropdownMenuItem<String>(
                      value: AppConstants.incomeType,
                      child: Text('Thu nhập'),
                    ),
                    DropdownMenuItem<String>(
                      value: AppConstants.expenseType,
                      child: Text('Chi tiêu'),
                    ),
                  ],
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedType = value;
                      _selectedCategory = AppConstants.categoriesFor(
                        value,
                      ).first;
                    });
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _amountController,
                  label: 'Số tiền',
                  hintText: 'Ví dụ: 150000',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  prefixIcon: Icons.payments_outlined,
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Số tiền không được bỏ trống';
                    }
                    final double? amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Số tiền phải lớn hơn 0';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  decoration: const InputDecoration(
                    labelText: 'Danh mục',
                    prefixIcon: Icon(Icons.category_outlined),
                  ),
                  items: categories
                      .map(
                        (String category) => DropdownMenuItem<String>(
                          value: category,
                          child: Text(category),
                        ),
                      )
                      .toList(),
                  onChanged: (String? value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Danh mục không được bỏ trống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _dateController,
                  label: 'Ngày giao dịch',
                  readOnly: true,
                  prefixIcon: Icons.calendar_month_rounded,
                  suffixIcon: IconButton(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.edit_calendar_rounded),
                  ),
                  onTap: _pickDate,
                  validator: (_) => null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _noteController,
                  label: 'Ghi chú',
                  hintText: 'Có thể để trống',
                  prefixIcon: Icons.sticky_note_2_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                CustomButton(
                  label: _isEditing ? 'Lưu thay đổi' : 'Lưu giao dịch',
                  icon: Icons.save_rounded,
                  isLoading: provider.isSubmitting,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
