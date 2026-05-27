import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/budget_model.dart';
import '../services/firestore_service.dart';

class BudgetProvider extends ChangeNotifier {
  BudgetProvider(this._firestoreService);

  final FirestoreService _firestoreService;

  StreamSubscription<BudgetModel?>? _subscription;
  String? _activeUserId;
  DateTime _selectedMonth = _monthStart(DateTime.now());
  BudgetModel? _currentBudget;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  DateTime get selectedMonth => _selectedMonth;
  BudgetModel? get currentBudget => _currentBudget;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasBudget => _currentBudget != null;

  void bindUser(String? userId) {
    if (_activeUserId == userId) {
      return;
    }

    _subscription?.cancel();
    _activeUserId = userId;

    if (userId == null) {
      _currentBudget = null;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _listenToSelectedMonthBudget();
  }

  void setSelectedMonth(DateTime month) {
    final DateTime normalizedMonth = _monthStart(month);
    if (_isSameMonth(_selectedMonth, normalizedMonth)) {
      return;
    }

    _selectedMonth = normalizedMonth;
    if (_activeUserId != null) {
      _listenToSelectedMonthBudget();
    } else {
      notifyListeners();
    }
  }

  Future<bool> saveSelectedMonthBudget(double amount) async {
    if (_activeUserId == null) {
      _errorMessage = 'Không tìm thấy người dùng hiện tại.';
      notifyListeners();
      return false;
    }

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final DateTime now = DateTime.now();
      final BudgetModel budget = BudgetModel(
        id: FirestoreService.budgetDocumentId(_selectedMonth),
        month: _selectedMonth.month,
        year: _selectedMonth.year,
        amount: amount,
        createdAt: _currentBudget?.createdAt ?? now,
        updatedAt: now,
      );

      await _firestoreService.upsertBudget(_activeUserId!, budget);
      _currentBudget = budget;
      return true;
    } catch (_) {
      _errorMessage = 'Không thể lưu ngân sách.';
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  Future<bool> saveCurrentMonthBudget(double amount) {
    return saveSelectedMonthBudget(amount);
  }

  double remainingBudget(double totalExpense) {
    final double budgetAmount = _currentBudget?.amount ?? 0;
    return budgetAmount - totalExpense;
  }

  bool isOverBudget(double totalExpense) {
    if (_currentBudget == null) {
      return false;
    }
    return totalExpense > _currentBudget!.amount;
  }

  String budgetStatusMessage(double totalExpense) {
    if (_currentBudget == null) {
      return 'Bạn chưa đặt ngân sách cho tháng đang xem.';
    }

    if (isOverBudget(totalExpense)) {
      return 'Bạn đã vượt ngân sách tháng đang xem';
    }

    return 'Bạn vẫn đang trong giới hạn ngân sách';
  }

  void _listenToSelectedMonthBudget() {
    final String? userId = _activeUserId;
    if (userId == null) {
      return;
    }

    _subscription?.cancel();
    _currentBudget = null;
    _isLoading = true;
    notifyListeners();

    _subscription = _firestoreService
        .streamBudgetForMonth(userId, _selectedMonth)
        .listen(
          (BudgetModel? budget) {
            _currentBudget = budget;
            _isLoading = false;
            _errorMessage = null;
            notifyListeners();
          },
          onError: (_) {
            _isLoading = false;
            _errorMessage = 'Không tải được ngân sách tháng đang xem.';
            notifyListeners();
          },
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

DateTime _monthStart(DateTime date) {
  return DateTime(date.year, date.month);
}
