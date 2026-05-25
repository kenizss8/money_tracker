import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/transaction_model.dart';
import '../services/firestore_service.dart';
import '../utils/app_constants.dart';

class TransactionProvider extends ChangeNotifier {
  TransactionProvider(this._firestoreService);

  final FirestoreService _firestoreService;

  StreamSubscription<List<TransactionModel>>? _subscription;
  String? _activeUserId;
  List<TransactionModel> _transactions = <TransactionModel>[];
  String _selectedFilter = AppConstants.filterAll;
  bool _showCurrentMonthOnly = false;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<TransactionModel> get transactions =>
      List<TransactionModel>.unmodifiable(_transactions);
  String get selectedFilter => _selectedFilter;
  bool get showCurrentMonthOnly => _showCurrentMonthOnly;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;

  void bindUser(String? userId) {
    if (_activeUserId == userId) {
      return;
    }

    _subscription?.cancel();
    _activeUserId = userId;

    if (userId == null) {
      _transactions = <TransactionModel>[];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService
        .streamTransactions(userId)
        .listen(
          (List<TransactionModel> items) {
            _transactions = List<TransactionModel>.from(items)
              ..sort(
                (TransactionModel a, TransactionModel b) =>
                    b.date.compareTo(a.date),
              );
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (_) {
            _isLoading = false;
            _errorMessage = 'Không tải được danh sách giao dịch.';
            notifyListeners();
          },
        );
  }

  void setFilter(String value) {
    _selectedFilter = value;
    notifyListeners();
  }

  void toggleCurrentMonthOnly(bool value) {
    _showCurrentMonthOnly = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  List<TransactionModel> get filteredTransactions {
    Iterable<TransactionModel> items = _transactions;

    if (_selectedFilter != AppConstants.filterAll) {
      items = items.where(
        (TransactionModel item) => item.type == _selectedFilter,
      );
    }

    if (_showCurrentMonthOnly) {
      items = items.where(
        (TransactionModel item) => _isSameMonth(item.date, DateTime.now()),
      );
    }

    return items.toList()..sort(
      (TransactionModel a, TransactionModel b) => b.date.compareTo(a.date),
    );
  }

  List<TransactionModel> get currentMonthTransactions {
    return _transactions
        .where(
          (TransactionModel item) => _isSameMonth(item.date, DateTime.now()),
        )
        .toList()
      ..sort(
        (TransactionModel a, TransactionModel b) => b.date.compareTo(a.date),
      );
  }

  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  double get totalIncome => _sumByType(_transactions, AppConstants.incomeType);
  double get totalExpense =>
      _sumByType(_transactions, AppConstants.expenseType);
  double get balance => totalIncome - totalExpense;

  double get currentMonthIncome =>
      _sumByType(currentMonthTransactions, AppConstants.incomeType);
  double get currentMonthExpense =>
      _sumByType(currentMonthTransactions, AppConstants.expenseType);
  double get currentMonthBalance => currentMonthIncome - currentMonthExpense;
  int get currentMonthTransactionCount => currentMonthTransactions.length;

  Map<String, double> get expenseByCategoryThisMonth {
    final Map<String, double> grouped = <String, double>{};

    for (final TransactionModel transaction in currentMonthTransactions) {
      if (transaction.type != AppConstants.expenseType) {
        continue;
      }
      grouped.update(
        transaction.category,
        (double value) => value + transaction.amount,
        ifAbsent: () => transaction.amount,
      );
    }

    final List<MapEntry<String, double>> entries = grouped.entries.toList()
      ..sort(
        (MapEntry<String, double> a, MapEntry<String, double> b) =>
            b.value.compareTo(a.value),
      );

    return Map<String, double>.fromEntries(entries);
  }

  List<MonthlyExpensePoint> get lastSixMonthsExpense {
    final DateTime now = DateTime.now();
    final List<MonthlyExpensePoint> points = <MonthlyExpensePoint>[];

    for (int i = 5; i >= 0; i--) {
      final DateTime month = DateTime(now.year, now.month - i, 1);
      double total = 0;

      for (final TransactionModel transaction in _transactions) {
        if (transaction.type == AppConstants.expenseType &&
            _isSameMonth(transaction.date, month)) {
          total += transaction.amount;
        }
      }

      points.add(MonthlyExpensePoint(month: month, total: total));
    }

    return points;
  }

  String get topExpenseCategory {
    if (expenseByCategoryThisMonth.isEmpty) {
      return 'Chưa có dữ liệu';
    }
    return expenseByCategoryThisMonth.entries.first.key;
  }

  String get statisticInsight {
    if (expenseByCategoryThisMonth.isEmpty) {
      return 'Bạn chưa có dữ liệu chi tiêu trong tháng này.';
    }
    return 'Bạn chi nhiều nhất cho $topExpenseCategory trong tháng này.';
  }

  Future<bool> addTransaction(TransactionModel transaction) async {
    if (_activeUserId == null) {
      _errorMessage = 'Không tìm thấy người dùng hiện tại.';
      notifyListeners();
      return false;
    }

    _setSubmitting(true);
    try {
      await _firestoreService.addTransaction(_activeUserId!, transaction);
      return true;
    } catch (_) {
      _errorMessage = 'Không thể thêm giao dịch.';
      notifyListeners();
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> updateTransaction(TransactionModel transaction) async {
    if (_activeUserId == null) {
      _errorMessage = 'Không tìm thấy người dùng hiện tại.';
      notifyListeners();
      return false;
    }

    _setSubmitting(true);
    try {
      await _firestoreService.updateTransaction(_activeUserId!, transaction);
      return true;
    } catch (_) {
      _errorMessage = 'Không thể cập nhật giao dịch.';
      notifyListeners();
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteTransaction(String transactionId) async {
    if (_activeUserId == null) {
      _errorMessage = 'Không tìm thấy người dùng hiện tại.';
      notifyListeners();
      return false;
    }

    _setSubmitting(true);
    try {
      await _firestoreService.deleteTransaction(_activeUserId!, transactionId);
      return true;
    } catch (_) {
      _errorMessage = 'Không thể xóa giao dịch.';
      notifyListeners();
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  Future<bool> deleteAllTransactions() async {
    if (_activeUserId == null) {
      _errorMessage = 'Không tìm thấy người dùng hiện tại.';
      notifyListeners();
      return false;
    }

    _setSubmitting(true);
    try {
      await _firestoreService.deleteAllTransactions(_activeUserId!);
      return true;
    } catch (_) {
      _errorMessage = 'Không thể xóa toàn bộ giao dịch.';
      notifyListeners();
      return false;
    } finally {
      _setSubmitting(false);
    }
  }

  void _setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  double _sumByType(List<TransactionModel> items, String type) {
    return items
        .where((TransactionModel item) => item.type == type)
        .fold<double>(
          0,
          (double sum, TransactionModel item) => sum + item.amount,
        );
  }

  bool _isSameMonth(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month;
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
