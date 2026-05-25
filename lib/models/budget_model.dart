import 'package:cloud_firestore/cloud_firestore.dart';

class BudgetModel {
  const BudgetModel({
    required this.id,
    required this.month,
    required this.year,
    required this.amount,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final int month;
  final int year;
  final double amount;
  final DateTime createdAt;
  final DateTime? updatedAt;

  BudgetModel copyWith({
    String? id,
    int? month,
    int? year,
    double? amount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      month: month ?? this.month,
      year: year ?? this.year,
      amount: amount ?? this.amount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'month': month,
      'year': year,
      'amount': amount,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt == null ? null : Timestamp.fromDate(updatedAt!),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String? ?? '',
      month: (map['month'] as num?)?.toInt() ?? 0,
      year: (map['year'] as num?)?.toInt() ?? 0,
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      createdAt: _asDateTime(map['createdAt']),
      updatedAt: map['updatedAt'] == null
          ? null
          : _asDateTime(map['updatedAt']),
    );
  }
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
