import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/transaction_model.dart';
import '../utils/app_constants.dart';
import '../utils/currency_formatter.dart';

const Color _background = Colors.black;
const Color _card = Color(0xFF1C1C1E);
const Color _softCard = Color(0xFF2C2C2E);
const Color _text = Colors.white;
const Color _muted = Color(0xFFA1A1AA);
const Color _green = Color(0xFF34D399);
const Color _blue = Color(0xFF60A5FA);
const Color _red = Color(0xFFFB7185);

class TransactionSearchScreen extends StatefulWidget {
  const TransactionSearchScreen({super.key, required this.transactions});

  final List<TransactionModel> transactions;

  @override
  State<TransactionSearchScreen> createState() =>
      _TransactionSearchScreenState();
}

class _TransactionSearchScreenState extends State<TransactionSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _keyword = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<TransactionModel> results = widget.transactions
        .where((TransactionModel item) => _matchesTransaction(item, _keyword))
        .toList();

    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Row(
                children: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Đóng',
                      style: TextStyle(
                        color: _green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Tìm giao dịch',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _text,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.tune_rounded, color: _text),
                  ),
                ],
              ),
            ),
            SearchTransactionInput(
              controller: _controller,
              onChanged: (String value) {
                setState(() {
                  _keyword = value;
                });
              },
            ),
            const SizedBox(height: 14),
            Expanded(
              child: SearchTransactionResultList(
                keyword: _keyword,
                transactions: results,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchTransactionInput extends StatelessWidget {
  const SearchTransactionInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        autofocus: true,
        cursorColor: _green,
        style: const TextStyle(
          color: _text,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: 'Tìm theo nhãn, nhóm, ví...',
          hintStyle: const TextStyle(color: _muted),
          prefixIcon: const Icon(Icons.search_rounded, color: _muted),
          filled: true,
          fillColor: _softCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(color: _green, width: 1.2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
        ),
      ),
    );
  }
}

class SearchTransactionResultList extends StatelessWidget {
  const SearchTransactionResultList({
    super.key,
    required this.keyword,
    required this.transactions,
  });

  final String keyword;
  final List<TransactionModel> transactions;

  @override
  Widget build(BuildContext context) {
    if (keyword.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Nhập từ khóa để tìm giao dịch',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    if (transactions.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Không tìm thấy giao dịch phù hợp',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _muted,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      itemCount: transactions.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (BuildContext context, int index) {
        return SearchTransactionItem(transaction: transactions[index]);
      },
    );
  }
}

class SearchTransactionItem extends StatelessWidget {
  const SearchTransactionItem({super.key, required this.transaction});

  final TransactionModel transaction;

  @override
  Widget build(BuildContext context) {
    final bool isIncome = transaction.type == AppConstants.incomeType;
    final Color amountColor = isIncome ? _blue : _red;
    final String prefix = isIncome ? '+' : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: <Widget>[
          CircleAvatar(
            radius: 25,
            backgroundColor: amountColor.withValues(alpha: 0.16),
            child: Icon(
              AppConstants.categoryIcon(transaction.category, transaction.type),
              color: amountColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  transaction.category,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _text,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '${transaction.note} • ${DateFormat('dd/MM/yyyy').format(transaction.date)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  transaction.type == AppConstants.incomeType
                      ? 'Thu nhập'
                      : 'Chi tiêu',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(
                '$prefix${CurrencyFormatter.format(transaction.amount)}',
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
    );
  }
}

bool _matchesTransaction(TransactionModel transaction, String keyword) {
  final String normalizedKeyword = keyword.trim().toLowerCase();
  if (normalizedKeyword.isEmpty) {
    return false;
  }

  final String typeLabel = transaction.type == AppConstants.incomeType
      ? 'thu nhập income'
      : 'chi tiêu expense';
  final String dateLabel = DateFormat('dd/MM/yyyy').format(transaction.date);

  return <String>[
    transaction.category,
    transaction.note,
    typeLabel,
    dateLabel,
  ].any((String value) => value.toLowerCase().contains(normalizedKeyword));
}
