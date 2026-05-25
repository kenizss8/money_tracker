import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppConstants {
  static const String appName = 'Money Tracker';
  static const String appTagline = 'Quản lý chi tiêu cá nhân';

  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String budgetsCollection = 'budgets';

  static const String incomeType = 'income';
  static const String expenseType = 'expense';

  static const String filterAll = 'all';
  static const String filterIncome = incomeType;
  static const String filterExpense = expenseType;

  static const Duration splashDuration = Duration(milliseconds: 1200);

  static const List<String> incomeCategories = <String>[
    'Lương',
    'Làm thêm',
    'Học bổng',
    'Tiền được cho',
    'Khác',
  ];

  static const List<String> expenseCategories = <String>[
    'Ăn uống',
    'Đi lại',
    'Mua sắm',
    'Học tập',
    'Giải trí',
    'Hóa đơn',
    'Sức khỏe',
    'Khác',
  ];

  static List<String> categoriesFor(String type) {
    if (type == incomeType) {
      return incomeCategories;
    }
    return expenseCategories;
  }

  static String transactionTypeLabel(String type) {
    return type == incomeType ? 'Thu nhập' : 'Chi tiêu';
  }

  static String filterLabel(String value) {
    switch (value) {
      case filterIncome:
        return 'Thu nhập';
      case filterExpense:
        return 'Chi tiêu';
      default:
        return 'Tất cả';
    }
  }

  static IconData categoryIcon(String category, String type) {
    if (type == incomeType) {
      switch (category) {
        case 'Lương':
          return Icons.payments_rounded;
        case 'Làm thêm':
          return Icons.work_history_rounded;
        case 'Học bổng':
          return Icons.school_rounded;
        case 'Tiền được cho':
          return Icons.card_giftcard_rounded;
        default:
          return Icons.savings_rounded;
      }
    }

    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant_rounded;
      case 'Đi lại':
        return Icons.directions_bus_rounded;
      case 'Mua sắm':
        return Icons.shopping_bag_rounded;
      case 'Học tập':
        return Icons.menu_book_rounded;
      case 'Giải trí':
        return Icons.movie_creation_outlined;
      case 'Hóa đơn':
        return Icons.receipt_long_rounded;
      case 'Sức khỏe':
        return Icons.favorite_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  static Color amountColor(String type) {
    return type == incomeType ? AppColors.success : AppColors.danger;
  }
}
