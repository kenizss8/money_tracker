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
  bool _initialHistorySeedChecked = false;
  bool _isSeedingInitialHistory = false;
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
    _initialHistorySeedChecked = false;
    _isSeedingInitialHistory = false;

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
            _seedInitialMayHistoryIfNeeded(items);
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

  Future<void> _seedInitialMayHistoryIfNeeded(
    List<TransactionModel> items,
  ) async {
    final String? userId = _activeUserId;
    if (userId == null ||
        _initialHistorySeedChecked ||
        _isSeedingInitialHistory) {
      return;
    }

    _initialHistorySeedChecked = true;

    try {
      final bool alreadySeeded = await _firestoreService.hasInitialHistorySeed(
        userId,
      );
      if (alreadySeeded) {
        return;
      }

      final Set<String> seedIds = _may2026Transactions()
          .map((TransactionModel transaction) => transaction.id)
          .toSet();
      final bool hasSeedTransactions = items.any(
        (TransactionModel transaction) => seedIds.contains(transaction.id),
      );
      if (hasSeedTransactions) {
        await _firestoreService.markInitialHistorySeeded(userId);
        return;
      }

      _isSeedingInitialHistory = true;
      await _firestoreService.upsertTransactions(
        userId,
        _may2026Transactions(),
      );
      await _firestoreService.markInitialHistorySeeded(userId);
    } catch (_) {
      // Không chặn app nếu dữ liệu lịch sử không nạp được.
    } finally {
      _isSeedingInitialHistory = false;
    }
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

List<TransactionModel> _may2026Transactions() {
  final DateTime createdAt = DateTime(2026, 5, 1, 8);
  final List<_TransactionSeed> items = <_TransactionSeed>[
    _TransactionSeed(
      '01a',
      AppConstants.expenseType,
      45000,
      'Ăn uống',
      'Bữa sáng',
      1,
    ),
    _TransactionSeed(
      '01b',
      AppConstants.expenseType,
      120000,
      'Đi lại',
      'Đổ xăng',
      1,
    ),
    _TransactionSeed(
      '02a',
      AppConstants.expenseType,
      85000,
      'Ăn uống',
      'Cà phê và ăn trưa',
      2,
    ),
    _TransactionSeed(
      '03a',
      AppConstants.expenseType,
      65000,
      'Đi lại',
      'Gửi xe và xe buýt',
      3,
    ),
    _TransactionSeed(
      '04a',
      AppConstants.expenseType,
      210000,
      'Mua sắm',
      'Đồ dùng cá nhân',
      4,
    ),
    _TransactionSeed(
      '05a',
      AppConstants.incomeType,
      6000000,
      'Lương',
      'Lương đầu tháng',
      5,
    ),
    _TransactionSeed(
      '05b',
      AppConstants.expenseType,
      350000,
      'Học tập',
      'Mua tài liệu',
      5,
    ),
    _TransactionSeed(
      '06a',
      AppConstants.expenseType,
      180000,
      'Ăn uống',
      'Ăn tối',
      6,
    ),
    _TransactionSeed(
      '07a',
      AppConstants.expenseType,
      750000,
      'Hóa đơn',
      'Tiền điện nước',
      7,
    ),
    _TransactionSeed(
      '08a',
      AppConstants.expenseType,
      260000,
      'Đi lại',
      'Taxi và gửi xe',
      8,
    ),
    _TransactionSeed(
      '09a',
      AppConstants.expenseType,
      145000,
      'Ăn uống',
      'Ăn trưa',
      9,
    ),
    _TransactionSeed(
      '10a',
      AppConstants.incomeType,
      900000,
      'Làm thêm',
      'Dạy kèm cuối tuần',
      10,
    ),
    _TransactionSeed(
      '10b',
      AppConstants.expenseType,
      420000,
      'Mua sắm',
      'Đồ dùng cá nhân',
      10,
    ),
    _TransactionSeed(
      '11a',
      AppConstants.expenseType,
      95000,
      'Ăn uống',
      'Ăn trưa',
      11,
    ),
    _TransactionSeed(
      '12a',
      AppConstants.expenseType,
      300000,
      'Giải trí',
      'Xem phim',
      12,
    ),
    _TransactionSeed(
      '13a',
      AppConstants.expenseType,
      150000,
      'Sức khỏe',
      'Mua thuốc',
      13,
    ),
    _TransactionSeed(
      '14a',
      AppConstants.expenseType,
      88000,
      'Đi lại',
      'Di chuyển trong ngày',
      14,
    ),
    _TransactionSeed(
      '15a',
      AppConstants.incomeType,
      1500000,
      'Tiền được cho',
      'Gia đình hỗ trợ',
      15,
    ),
    _TransactionSeed(
      '15b',
      AppConstants.expenseType,
      240000,
      'Ăn uống',
      'Ăn uống cùng bạn',
      15,
    ),
    _TransactionSeed(
      '16a',
      AppConstants.expenseType,
      680000,
      'Mua sắm',
      'Quần áo',
      16,
    ),
    _TransactionSeed(
      '17a',
      AppConstants.expenseType,
      110000,
      'Đi lại',
      'Xe buýt và gửi xe',
      17,
    ),
    _TransactionSeed(
      '18a',
      AppConstants.expenseType,
      220000,
      'Ăn uống',
      'Ăn cuối tuần',
      18,
    ),
    _TransactionSeed(
      '19a',
      AppConstants.expenseType,
      125000,
      'Khác',
      'Chi phí phát sinh',
      19,
    ),
    _TransactionSeed(
      '20a',
      AppConstants.expenseType,
      520000,
      'Hóa đơn',
      'Internet',
      20,
    ),
    _TransactionSeed(
      '21a',
      AppConstants.incomeType,
      700000,
      'Làm thêm',
      'Thiết kế bài tập',
      21,
    ),
    _TransactionSeed(
      '21b',
      AppConstants.expenseType,
      175000,
      'Ăn uống',
      'Ăn tối',
      21,
    ),
    _TransactionSeed(
      '22a',
      AppConstants.expenseType,
      390000,
      'Học tập',
      'Khóa học online',
      22,
    ),
    _TransactionSeed(
      '23a',
      AppConstants.expenseType,
      800000,
      'Mua sắm',
      'Phụ kiện điện thoại',
      23,
    ),
    _TransactionSeed(
      '24a',
      AppConstants.expenseType,
      210000,
      'Ăn uống',
      'Ăn uống cùng bạn',
      24,
    ),
    _TransactionSeed(
      '25a',
      AppConstants.expenseType,
      320000,
      'Sức khỏe',
      'Khám sức khỏe',
      25,
    ),
    _TransactionSeed(
      '26a',
      AppConstants.expenseType,
      140000,
      'Đi lại',
      'Di chuyển trong ngày',
      26,
    ),
    _TransactionSeed(
      '27a',
      AppConstants.incomeType,
      1200000,
      'Học bổng',
      'Hỗ trợ học tập',
      27,
    ),
    _TransactionSeed(
      '27b',
      AppConstants.expenseType,
      98000,
      'Ăn uống',
      'Ăn trưa',
      27,
    ),
    _TransactionSeed(
      '28a',
      AppConstants.expenseType,
      160000,
      'Ăn uống',
      'Ăn tối',
      28,
    ),
    _TransactionSeed(
      '29a',
      AppConstants.expenseType,
      270000,
      'Giải trí',
      'Cà phê cuối tuần',
      29,
    ),
    _TransactionSeed(
      '30a',
      AppConstants.expenseType,
      450000,
      'Giải trí',
      'Đi chơi cuối tuần',
      30,
    ),
    _TransactionSeed(
      '31a',
      AppConstants.expenseType,
      250000,
      'Khác',
      'Chi phí phát sinh',
      31,
    ),
  ];

  return items.map((_TransactionSeed item) {
    return TransactionModel(
      id: 'may_2026_${item.id}',
      type: item.type,
      amount: item.amount,
      category: item.category,
      note: item.note,
      date: DateTime(2026, 5, item.day, 12),
      createdAt: createdAt,
    );
  }).toList();
}

class _TransactionSeed {
  const _TransactionSeed(
    this.id,
    this.type,
    this.amount,
    this.category,
    this.note,
    this.day,
  );

  final String id;
  final String type;
  final double amount;
  final String category;
  final String note;
  final int day;
}
