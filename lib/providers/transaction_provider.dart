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
  DateTime _selectedMonth = _monthStart(DateTime.now());
  String _selectedFilter = AppConstants.filterAll;
  bool _showSelectedMonthOnly = true;
  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _errorMessage;

  List<TransactionModel> get transactions =>
      List<TransactionModel>.unmodifiable(_transactions);
  DateTime get selectedMonth => _selectedMonth;
  String get selectedFilter => _selectedFilter;
  bool get showCurrentMonthOnly => _showSelectedMonthOnly;
  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String? get errorMessage => _errorMessage;
  bool get isViewingCurrentMonth =>
      _isSameMonth(_selectedMonth, DateTime.now());

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
    _showSelectedMonthOnly = value;
    notifyListeners();
  }

  void setSelectedMonth(DateTime month) {
    final DateTime normalizedMonth = _monthStart(month);
    if (_isAfterCurrentMonth(normalizedMonth) ||
        _isSameMonth(_selectedMonth, normalizedMonth)) {
      return;
    }

    _selectedMonth = normalizedMonth;
    notifyListeners();
  }

  void goToPreviousMonth() {
    _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    notifyListeners();
  }

  void goToNextMonth() {
    final DateTime nextMonth = DateTime(
      _selectedMonth.year,
      _selectedMonth.month + 1,
    );

    if (_isAfterCurrentMonth(nextMonth)) {
      return;
    }

    _selectedMonth = nextMonth;
    notifyListeners();
  }

  void resetToCurrentMonth() {
    final DateTime currentMonth = _monthStart(DateTime.now());
    if (_isSameMonth(_selectedMonth, currentMonth)) {
      return;
    }

    _selectedMonth = currentMonth;
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

    if (_showSelectedMonthOnly) {
      items = items.where(
        (TransactionModel item) => _isSameMonth(item.date, _selectedMonth),
      );
    }

    return items.toList()..sort(
      (TransactionModel a, TransactionModel b) => b.date.compareTo(a.date),
    );
  }

  List<TransactionDayGroup> get filteredTransactionGroups {
    return _groupByDate(filteredTransactions);
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

  List<TransactionModel> get selectedMonthTransactions {
    return _transactions
        .where(
          (TransactionModel item) => _isSameMonth(item.date, _selectedMonth),
        )
        .toList()
      ..sort(
        (TransactionModel a, TransactionModel b) => b.date.compareTo(a.date),
      );
  }

  List<TransactionModel> get recentTransactions {
    return _transactions.take(5).toList();
  }

  List<TransactionModel> get selectedMonthRecentTransactions {
    return selectedMonthTransactions.take(5).toList();
  }

  List<TransactionDayGroup> get selectedMonthRecentTransactionGroups {
    return _groupByDate(selectedMonthRecentTransactions);
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

  double get selectedMonthIncome =>
      _sumByType(selectedMonthTransactions, AppConstants.incomeType);
  double get selectedMonthExpense =>
      _sumByType(selectedMonthTransactions, AppConstants.expenseType);
  double get selectedMonthBalance => selectedMonthIncome - selectedMonthExpense;
  int get selectedMonthTransactionCount => selectedMonthTransactions.length;

  Map<String, double> get expenseByCategoryThisMonth {
    return _expenseByCategory(currentMonthTransactions);
  }

  Map<String, double> get expenseByCategorySelectedMonth {
    return _expenseByCategory(selectedMonthTransactions);
  }

  List<MonthlyExpensePoint> get lastSixMonthsExpense {
    final List<MonthlyExpensePoint> points = <MonthlyExpensePoint>[];

    for (int i = 5; i >= 0; i--) {
      final DateTime month = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - i,
      );
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
    if (expenseByCategorySelectedMonth.isEmpty) {
      return 'Chưa có dữ liệu';
    }
    return expenseByCategorySelectedMonth.entries.first.key;
  }

  String get statisticInsight {
    if (expenseByCategorySelectedMonth.isEmpty) {
      return 'Bạn chưa có dữ liệu chi tiêu trong tháng đang xem.';
    }
    return 'Bạn chi nhiều nhất cho $topExpenseCategory trong tháng đang xem.';
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

  Map<String, double> _expenseByCategory(List<TransactionModel> items) {
    final Map<String, double> grouped = <String, double>{};

    for (final TransactionModel transaction in items) {
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

  List<TransactionDayGroup> _groupByDate(List<TransactionModel> items) {
    final List<TransactionModel> sortedItems =
        List<TransactionModel>.from(items)..sort(
          (TransactionModel a, TransactionModel b) => b.date.compareTo(a.date),
        );
    final List<TransactionDayGroup> groups = <TransactionDayGroup>[];

    for (final TransactionModel transaction in sortedItems) {
      final DateTime date = _dayStart(transaction.date);

      if (groups.isEmpty || !_isSameDay(groups.last.date, date)) {
        groups.add(
          TransactionDayGroup(
            date: date,
            transactions: <TransactionModel>[transaction],
          ),
        );
        continue;
      }

      final TransactionDayGroup lastGroup = groups.removeLast();
      groups.add(
        TransactionDayGroup(
          date: lastGroup.date,
          transactions: <TransactionModel>[
            ...lastGroup.transactions,
            transaction,
          ],
        ),
      );
    }

    return groups;
  }

  bool _isSameMonth(DateTime left, DateTime right) {
    return left.year == right.year && left.month == right.month;
  }

  bool _isSameDay(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  bool _isAfterCurrentMonth(DateTime month) {
    final DateTime currentMonth = _monthStart(DateTime.now());
    return month.year > currentMonth.year ||
        (month.year == currentMonth.year && month.month > currentMonth.month);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

DateTime _monthStart(DateTime date) {
  return DateTime(date.year, date.month);
}

DateTime _dayStart(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}
