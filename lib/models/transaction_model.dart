import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String type;
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  final DateTime? updatedAt;

  TransactionModel copyWith({
    String? id,
    String? type,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'note': note,
      'date': Timestamp.fromDate(date),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      category: map['category'] as String? ?? '',
      note: map['note'] as String? ?? '',
      date: _asDateTime(map['date']),
      createdAt: _asDateTime(map['createdAt']),
      updatedAt: map['updatedAt'] == null
          ? null
          : _asDateTime(map['updatedAt']),
    );
  }
}

class MonthlyExpensePoint {
  const MonthlyExpensePoint({required this.month, required this.total});

  final DateTime month;
  final double total;
}

class TransactionDayGroup {
  const TransactionDayGroup({required this.date, required this.transactions});

  final DateTime date;
  final List<TransactionModel> transactions;

  double get incomeTotal => transactions
      .where((TransactionModel item) => item.type == 'income')
      .fold<double>(
        0,
        (double sum, TransactionModel item) => sum + item.amount,
      );

  double get expenseTotal => transactions
      .where((TransactionModel item) => item.type == 'expense')
      .fold<double>(
        0,
        (double sum, TransactionModel item) => sum + item.amount,
      );

  double get balance => incomeTotal - expenseTotal;
}

DateTime _asDateTime(dynamic value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}
